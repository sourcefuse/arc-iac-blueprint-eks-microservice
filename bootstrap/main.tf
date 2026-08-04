# =============================================================================
# bootstrap
# =============================================================================
# Creates S3 bucket (versioned) + DynamoDB table (lock) for Terraform state.
# Run ONCE before any other layer. No remote backend — state stays local.
# Publishes the backend config to SSM so downstream layers / CI can resolve it.
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Provisions the versioned S3 state bucket and DynamoDB lock table used by all downstream layers.
module "bootstrap" {
  source  = "sourcefuse/arc-bootstrap/aws"
  version = "1.1.11"

  bucket_name                   = "${var.namespace}-${var.environment}-terraform-state"
  enable_versioning             = true
  enable_bucket_force_destroy   = var.enable_bucket_force_destroy
  enable_s3_public_access_block = true
  sse_algorithm                 = "AES256"

  dynamodb_name                          = "${var.namespace}-${var.environment}-terraform-locks"
  dynamodb_hash_key                      = "LockID"
  enable_dynamodb_point_in_time_recovery = true

  tags = {
    Namespace   = var.namespace
    Environment = var.environment
    ManagedBy   = "terraform"
    Layer       = "bootstrap"
  }
}

resource "aws_ssm_parameter" "terraform_backend_config" {
  name = "/${var.namespace}/${var.environment}/terraform/backend-config"
  type = "String"

  value = jsonencode({
    bucket_name   = module.bootstrap.bucket_name
    dynamodb_name = module.bootstrap.dynamodb_name
    region        = var.region
  })

  tags = {
    Namespace   = var.namespace
    Environment = var.environment
    ManagedBy   = "terraform"
    Layer       = "bootstrap"
  }
}
