# Look up the platform VPC provisioned by the 01-network layer by its Name tag.
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

# Private subnets in the platform VPC — Aurora is deployed here (never public).
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
