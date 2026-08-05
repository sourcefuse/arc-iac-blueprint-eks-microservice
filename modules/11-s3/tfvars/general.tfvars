# =============================================================================
# 11-s3 - General Compliance Profile
# =============================================================================
# Standard S3 bucket settings for non-regulated workloads.
#
# Compliance controls enabled:
#   - AES256 server-side encryption at rest
#   - No Object Lock (WORM) — not required for general workloads
#   - No access logging — disabled for cost optimisation
#
# For HIPAA/PHI workloads, use: hipaa.tfvars
# For PCI-DSS cardholder data workloads, use: pci.tfvars

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
      id     = "expire-logs"
      status = "Enabled"

      expiration = {
        days = 90
      }
    }
  ]
}