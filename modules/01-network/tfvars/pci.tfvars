# =============================================================================
# 01-network - PCI DSS Compliance Profile
# =============================================================================
# PCI DSS-hardening controls applied to the network layer:
#   - enable_vpc_endpoints: S3/DynamoDB traffic stays on the AWS backbone,
#     reducing the cardholder-data environment's public exposure (Req. 1).
#   - vpc_flow_log retention raised to 365 days to satisfy log-retention
#     requirements (Req. 10.7).
#   - 3 availability zones for resilient segmentation of the CDE.
#   - Dedicated /16 range (10.3.0.0/16) isolated from other environments.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

vpc_cidr           = "10.3.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Single regional (multi-AZ) NAT gateway — resilient egress for the CDE.
nat_gateway_config = {
  mode               = "regional"
  regional_auto_mode = true
}

enable_vpc_endpoints = true

vpc_flow_log_config = {
  enable            = true
  retention_in_days = 365
  s3_bucket_arn     = null
  traffic_type      = "ALL"
}
