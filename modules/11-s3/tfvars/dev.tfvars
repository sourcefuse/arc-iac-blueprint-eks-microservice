namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

enable_versioning = true

object_lock_enabled = false

object_lock_config = {
  mode = "COMPLIANCE"
  days = 30
}

server_side_encryption_config_data = {
  bucket_key_enabled = true
  sse_algorithm      = "AES256"
  kms_master_key_id  = null
}

bucket_logging_data = {
  enable        = false
  target_bucket = null
  target_prefix = null
}

lifecycle_config = {
  enabled = true
  rules = [
    {
      id     = "expire-noncurrent"
      status = "Enabled"

      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
    }
  ]
}
