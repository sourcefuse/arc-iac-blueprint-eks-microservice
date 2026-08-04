# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "05-ecr"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# Provisions the ECR repository that application container images are pushed
# to and pulled from by the EKS cluster.
module "ecr" {
  source  = "sourcefuse/arc-ecr/aws"
  version = "0.0.4"

  repositories = {
    "${local.name_prefix}-app" = {
      image_tag_mutability = var.image_tag_mutability
      scan_on_push         = true
      encryption_type      = var.encryption_type
      force_delete         = var.force_delete
    }
  }

  tags = local.tags
}
