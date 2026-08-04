# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "06-aurora"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# Provisions the Aurora PostgreSQL cluster used as the platform's persistent
# data store (writer instance, subnet group, security group, and KMS key).
module "aurora" {
  source  = "sourcefuse/arc-db/aws"
  version = "4.0.4"

  namespace      = var.namespace
  environment    = var.environment
  name           = "${local.name_prefix}-aurora"
  engine         = local.engine
  engine_type    = "cluster"
  engine_version = local.engine_version
  engine_mode    = "provisioned"
  license_model  = "postgresql-license"
  port           = local.port
  username       = local.username

  vpc_id = data.aws_vpc.this.id

  db_subnet_group_data = {
    name       = "${local.name_prefix}-aurora-subnet-grp"
    create     = true
    subnet_ids = data.aws_subnets.private.ids
  }

  rds_cluster_instances = local.rds_cluster_instances

  security_group_data = {
    create = true
    ingress_rules = [
      {
        description = "PostgreSQL access from within the VPC"
        cidr_block  = data.aws_vpc.this.cidr_block
        from_port   = local.port
        ip_protocol = "tcp"
        to_port     = tostring(local.port)
      }
    ]
    egress_rules = []
  }

  kms_data = {
    create                  = true
    description             = "KMS key for ${local.name_prefix} Aurora encryption"
    deletion_window_in_days = var.kms_deletion_window_in_days
    enable_key_rotation     = true
  }

  manage_user_password            = true
  storage_encrypted               = true
  performance_insights_enabled    = true
  backup_retention_period         = var.backup_retention
  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = local.tags
}
