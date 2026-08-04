terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      # arc-github-runner 0.2.9 uses aws_eip.vpc (removed in aws v6), so this
      # layer pins aws < 6. It's an independent layer/state, so no conflict with
      # arc-eks (aws >= 6) elsewhere.
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}
