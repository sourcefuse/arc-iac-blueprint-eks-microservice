namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Single regional (multi-AZ) NAT gateway — HA egress, AWS-managed AZs/EIPs.
nat_gateway_config = {
  mode               = "regional"
  regional_auto_mode = true
}
