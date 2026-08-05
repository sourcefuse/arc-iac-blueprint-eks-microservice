# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "02-vpn"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# ---------------------------------------------------------------------------
# Certificates (mutual TLS)
# ---------------------------------------------------------------------------
# Self-signed CA that signs both the server and the client (root) certificates.
# Certs are imported to ACM (for the endpoint) and stored in SSM (for operators
# to retrieve), never written to local disk in CI.
module "ca" {
  source  = "sourcefuse/arc-vpn/aws//modules/certificate"
  version = "3.0.1"

  name        = "${local.name_prefix}-client-vpn-ca"
  type        = "ca"
  namespace   = var.namespace
  environment = var.environment

  subject = {
    common_name  = "ca.${local.name_prefix}.vpn"
    organization = var.namespace
  }

  import_to_acm    = true
  store_in_ssm     = true
  store_it_locally = false
}

# Client root certificate — its ACM ARN is the endpoint's
# root_certificate_chain_arn. Operators download this cert + key from SSM to
# build their .ovpn client profile.
module "root" {
  source  = "sourcefuse/arc-vpn/aws//modules/certificate"
  version = "3.0.1"

  name               = "${local.name_prefix}-client-vpn-root"
  type               = "root"
  namespace          = var.namespace
  environment        = var.environment
  ca_cert_pem        = module.ca.ca_cert_pem
  ca_private_key_pem = module.ca.private_key_pem

  subject = {
    common_name  = "root.${local.name_prefix}.vpn"
    organization = var.namespace
  }

  import_to_acm    = true
  store_in_ssm     = true
  store_it_locally = false
}

# ---------------------------------------------------------------------------
# Client VPN endpoint
# ---------------------------------------------------------------------------
# Certificate-authenticated (mutual TLS) Client VPN. Associates its target
# network with the private subnets and authorizes the VPC CIDR so operators can
# reach the private EKS API server and other private resources (Aurora, Redis,
# internal ALBs). Only one VPC/VPN here, so no additional routes are needed.
module "vpn" {
  source  = "sourcefuse/arc-vpn/aws"
  version = "3.0.1"

  name        = "${local.name_prefix}-client-vpn"
  namespace   = var.namespace
  environment = var.environment
  vpc_id      = data.aws_vpc.this.id

  client_vpn_config = {
    create = true
    # Client address pool. MUST NOT overlap the VPC/subnet CIDRs, or AWS rejects
    # the subnet association (InvalidClientVpnSubnetId.OverlappingCidr). A
    # cidrsubnet(vpc_cidr,...) slice lands inside this VPC's /18 subnets, so we
    # use a dedicated non-overlapping range (default 172.16.0.0/22) instead.
    client_cidr_block = var.client_cidr_block
    split_tunnel      = true
    subnet_ids        = data.aws_subnets.private.ids

    server_certificate_data = {
      create             = true
      common_name        = "${local.name_prefix}.server.vpn"
      organization       = var.namespace
      ca_cert_pem        = module.ca.ca_cert_pem
      ca_private_key_pem = module.ca.private_key_pem
    }

    authentication_options = [
      {
        type                       = "certificate-authentication"
        root_certificate_chain_arn = module.root.certificate_arn
      }
    ]

    authorization_options = local.authorization_options
  }

  tags = local.tags
}
