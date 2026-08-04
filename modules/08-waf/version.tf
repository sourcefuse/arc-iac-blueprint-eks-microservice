terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  backend "s3" {}
}

# CLOUDFRONT-scope Web ACLs can only be created in us-east-1, so this layer pins
# the provider region regardless of var.region.
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = local.tags
  }
}
