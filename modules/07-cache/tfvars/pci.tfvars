# =============================================================================
# PCI-DSS profile controls (07-cache / ElastiCache Redis)
# -----------------------------------------------------------------------------
# - Encryption in transit (TLS) and at rest with a customer-managed KMS key are
#   always ON (enforced in main.tf), meeting PCI-DSS Req. 3 (protect stored
#   cardholder data) and Req. 4 (encrypt transmission across networks).
# - Ingress is restricted to the VPC CIDR on the Redis port only (Req. 1).
# - automatic_failover_enabled + 3 cache clusters ensure high availability.
# =============================================================================
namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

node_type                  = "cache.m6g.large"
engine_version             = "7.0"
num_cache_clusters         = 3
automatic_failover_enabled = true
