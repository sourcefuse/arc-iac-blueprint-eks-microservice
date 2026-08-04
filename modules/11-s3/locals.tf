locals {
  # Shared name prefix used across all S3 resources.
  name_prefix = "${var.namespace}-${var.environment}"

  # Private bucket that stores the static frontend (SPA) assets and serves as the
  # CloudFront S3 origin (read via OAC). CloudFront access logs land here too.
  # Convention: <namespace>-<env>-frontend.
  bucket_name = "${local.name_prefix}-frontend"

  enable_versioning                  = var.enable_versioning
  server_side_encryption_config_data = var.server_side_encryption_config_data
  object_lock_enabled                = var.object_lock_enabled
  object_lock_config                 = var.object_lock_enabled ? var.object_lock_config : null
  bucket_logging_data                = var.bucket_logging_data
  lifecycle_config                   = var.lifecycle_config
}
