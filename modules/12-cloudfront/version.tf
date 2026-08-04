terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {}
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = module.tags.tags
  }
}