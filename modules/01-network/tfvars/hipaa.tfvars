# =============================================================================
# 01-network - HIPAA Compliance Profile
# =============================================================================
# HIPAA-hardening controls applied to the network layer:
#   - enable_vpc_endpoints: S3/DynamoDB traffic stays on the AWS backbone
#     instead of egressing via NAT/the public internet.
#   - vpc_flow_log retention raised to 365 days for audit/forensics.
#   - 3 availability zones for higher availability of PHI workloads.
#   - Dedicated /16 range (10.2.0.0/16) isolated from other environments.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "hipaa"

vpc_cidr           = "10.2.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Single regional (multi-AZ) NAT gateway — resilient egress for PHI workloads.
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
