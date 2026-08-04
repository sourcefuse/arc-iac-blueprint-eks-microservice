locals {
  name_prefix = "${var.namespace}-${var.environment}"
  tags        = module.tags.tags

  engine         = "aurora-postgresql"
  engine_version = var.engine_version
  port           = 5432
  username       = "dbadmin"

  # A single writer instance for the Aurora cluster. Add more objects here to
  # provision read replicas (promotion_tier controls failover ordering).
  rds_cluster_instances = [
    {
      instance_class = var.instance_class
      promotion_tier = 0
    }
  ]
}
