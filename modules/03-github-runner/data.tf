# Platform VPC (01-network) + a private subnet. The runner sits in a private
# subnet so it can reach the EKS PRIVATE API endpoint (same VPC).
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

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

# Current Ubuntu 22.04 LTS AMI. The arc-github-runner module defaults to Ubuntu
# 18.04 (bionic), which Canonical no longer publishes, so its built-in AMI
# lookup returns nothing — pass a live AMI id instead.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
