# Look up the platform VPC provisioned by the 01-network layer by its Name tag,
# so this module stays independently plan/validate-able (no terraform_remote_state).
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

# Private subnets — the Client VPN endpoint associates its target network here so
# client traffic egresses through the private subnets (and their NAT gateways).
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}
