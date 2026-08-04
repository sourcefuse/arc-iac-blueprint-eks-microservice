# =============================================================================
# HIPAA profile controls (07-cache / ElastiCache Redis)
# -----------------------------------------------------------------------------
# - Encryption in transit and at rest are always ON (enforced in main.tf) using
#   the shared customer-managed KMS key, satisfying the HIPAA Security Rule
#   requirement to protect ePHI at rest and in motion.
# - automatic_failover_enabled + >=2 cache clusters provide the multi-AZ
#   redundancy required for availability of ePHI.
# - Larger node_type gives headroom to avoid eviction of session/PHI data.
# =============================================================================
namespace          = "eb"
environment        = "prod"
compliance_profile = "hipaa"

node_type                  = "cache.m6g.large"
engine_version             = "7.0"
num_cache_clusters         = 3
automatic_failover_enabled = true
