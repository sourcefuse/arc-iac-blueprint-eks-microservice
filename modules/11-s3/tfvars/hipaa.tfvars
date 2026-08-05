# =============================================================================
# 11-s3 - HIPAA Compliance Profile
# =============================================================================
# Designed for HIPAA-regulated workloads containing PHI.
#
# Compliance controls enabled:
#   - SSE-KMS with a customer-managed CMK (set kms_master_key_id to your CMK ARN)
#   - Access logging enabled for audit trail
#   - Lifecycle rules: transition to GLACIER after 90 days
#
# Defense-in-depth (NOT mandated by the HIPAA Security Rule):
#   - WORM via Object Lock (30-day COMPLIANCE mode). HIPAA does not require
#     Object Lock; it is an optional integrity control. COMPLIANCE mode is
#     irreversible — even root cannot delete locked object versions before
#     expiry. Most appropriate on a dedicated audit-log bucket rather than the
#     application bucket; review before enabling in production.
#
# Note: set kms_master_key_id to the ARN of your KMS CMK. If this module shares
# a KMS key with other modules, wire it in via terraform_remote_state or a
# data source.
#
# Reference: HIPAA Security Rule 45 CFR 164.312(a)(2)(iv) - Encryption

namespace          = "eb"
environment        = "prod"
compliance_profile = "hipaa"

enable_versioning = true

object_lock_enabled = true

object_lock_config = {
  mode = "COMPLIANCE"
  days = 30
}

server_side_encryption_config_data = {
  bucket_key_enabled = true
  sse_algorithm      = "aws:kms"
  kms_master_key_id  = null # Replace with your CMK ARN or wire from remote state
}

bucket_logging_data = {
  enable        = true
  target_bucket = null # Resolved at apply time to the logging bucket
  target_prefix = "cloudfront-logs/"
}

lifecycle_config = {
  enabled = true
  rules = [
    {
      id     = "phi-archive"
      status = "Enabled"
      expiration = {
        days = 365
      }
      transitions = [
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]
}
