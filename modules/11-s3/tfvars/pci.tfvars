# =============================================================================
# 11-s3 - PCI-DSS Compliance Profile
# =============================================================================
# Designed for PCI-DSS cardholder data environments (CDE).
#
# Compliance controls enabled:
#   - Customer-managed KMS (SSE-KMS) for stored data (PCI DSS v4.0 Req 3)
#   - Access logging enabled for audit trail (PCI DSS v4.0 Req 10)
#   - Lifecycle rules for data retention and archival
#
# Defense-in-depth (NOT mandated by PCI DSS):
#   - WORM via Object Lock (90-day COMPLIANCE mode). PCI DSS does NOT require
#     Object Lock; it requires that audit logs be protected from modification
#     (Req 10.5) and integrity-monitored (Req 11.5). Object Lock is one strong
#     way to achieve immutability. COMPLIANCE mode is irreversible — even root
#     cannot delete locked object versions before expiry. Most appropriate on a
#     dedicated audit-log bucket; review before enabling in production.
#
# Note: set kms_master_key_id to the ARN of your KMS CMK.
#
# Reference: PCI DSS v4.0 - Requirement 3 (Protect Stored Account Data),
#            Requirement 10 (Logging and Monitoring)

namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

enable_versioning = true

object_lock_enabled = true

object_lock_config = {
  mode = "COMPLIANCE"
  days = 90
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
      id     = "cardholder-data-archive"
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
