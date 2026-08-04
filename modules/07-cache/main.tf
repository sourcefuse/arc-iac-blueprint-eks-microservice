# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "07-cache"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# Dedicated customer-managed CMK for this layer's at-rest encryption. Each layer
# owns its own key (there is no shared KMS module) so blast radius and key
# policy stay scoped to the resource that uses them.
module "kms" {
  source  = "sourcefuse/arc-kms/aws"
  version = "1.0.13"

  alias                   = "alias/${local.name_prefix}-cache"
  description             = "CMK for ${local.name_prefix} ElastiCache Redis at-rest encryption."
  policy                  = data.aws_iam_policy_document.kms.json
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  tags = local.tags
}

# Provisions the ElastiCache Redis replication group used as the platform's
# session store and caching layer, with encryption in transit and at rest.
module "cache" {
  source  = "sourcefuse/arc-cache/aws"
  version = "0.0.7"

  name       = "${local.name_prefix}-redis"
  tags       = local.tags
  vpc_id     = data.aws_vpc.this.id
  subnet_ids = data.aws_subnets.private.ids

  node_type          = var.node_type
  engine_version     = var.engine_version
  num_cache_clusters = var.num_cache_clusters

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  kms_key_id                 = module.kms.key_arn

  automatic_failover_enabled = var.automatic_failover_enabled

  create_security_group = true
  security_group_rules = {
    ingress = {
      redis = {
        description = "Redis access from within the VPC"
        from_port   = var.port
        to_port     = var.port
        protocol    = "tcp"
        cidr_blocks = [data.aws_vpc.this.cidr_block]
      }
    }
    egress = {
      all = {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  }
}
