locals {
  name_prefix = "${var.namespace}-${var.environment}"
  tags        = module.tags.tags

  # Single authorization rule: allow the local VPC CIDR. This is what lets
  # connected clients reach the private EKS API, internal ALBs, Aurora and Redis.
  # (Only one VPC/VPN here, so no additional target networks / routes.)
  authorization_options = {
    "vpc" = {
      target_network_cidr  = data.aws_vpc.this.cidr_block
      access_group_id      = null
      authorize_all_groups = true
    }
  }
}
