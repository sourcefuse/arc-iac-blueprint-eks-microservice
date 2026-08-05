# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "01-network"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# Provisions the VPC, public/private subnets, internet gateway, NAT, flow logs
# and (optionally) VPC endpoints used by every other module in this blueprint.
module "network" {
  source  = "sourcefuse/arc-network/aws"
  version = "3.0.15"

  namespace   = var.namespace
  environment = var.environment
  name        = local.name_prefix

  cidr_block              = var.vpc_cidr
  availability_zones      = var.availability_zones
  create_internet_gateway = true

  # Subnet tags the AWS Load Balancer Controller uses to auto-discover where to
  # place ALBs: public subnets for internet-facing ingress, private for internal.
  additional_public_subnet_tags  = { "kubernetes.io/role/elb" = "1" }
  additional_private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }

  # A single regional (multi-AZ) NAT gateway: AWS keeps it available across AZs,
  # giving HA egress without one NAT gateway + EIP per AZ. See var.nat_gateway_config
  # to switch to the traditional one-per-AZ (zonal) topology.
  nat_gateway_config = var.nat_gateway_config

  vpc_flow_log_config = local.vpc_flow_log_config
  vpc_endpoint_data   = local.vpc_endpoint_data
  instance_tenancy    = var.instance_tenancy

  tags = local.tags
}
