# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.8"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "11-s3"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# Provisions the private S3 bucket that holds the static frontend (SPA) assets
# and backs the CloudFront S3 origin (12-cloudfront), with compliance-aware
# encryption, versioning, object lock, and lifecycle rules.
module "s3" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.8"

  name              = local.bucket_name
  enable_versioning = local.enable_versioning

  public_access_config = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  object_lock_enabled                = local.object_lock_enabled
  object_lock_config                 = local.object_lock_config
  server_side_encryption_config_data = local.server_side_encryption_config_data
  bucket_logging_data                = local.bucket_logging_data
  lifecycle_config                   = local.lifecycle_config

  tags = module.tags.tags
}
