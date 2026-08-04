terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # arc-vpn's client-vpn/certificate submodules pin aws ">= 4.0, < 6.0",
      # so this layer stays on the v5 line (the rest of the blueprint allows v6).
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
