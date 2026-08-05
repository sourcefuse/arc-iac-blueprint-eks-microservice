# =============================================================================
# 04-eks - PCI DSS Compliance Profile
# =============================================================================
# Controls:
#  - Secrets envelope encryption is enforced via the shared KMS key (main.tf),
#    satisfying PCI DSS requirements for protecting stored credentials.
#  - Node group runs on dedicated m5.xlarge instances sized for production
#    cardholder-data workloads; capacity is kept at the general baseline.
#  - API server endpoint is PRIVATE-only (endpoint_public_access=false, main.tf);
#    reach it from inside the VPC via a self-hosted runner — good for PCI DSS.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

kubernetes_version  = "1.36"

# Compute model: false = managed node groups (below); true = EKS Auto Mode.
enable_auto_mode    = false
node_instance_types = ["m5.xlarge"]
node_desired_size   = 3
node_min_size       = 2
node_max_size       = 10

# Control-plane logging -> CloudWatch for a full API-server audit trail
# (api = API access, audit = authz decisions, authenticator = IAM auth).
enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
