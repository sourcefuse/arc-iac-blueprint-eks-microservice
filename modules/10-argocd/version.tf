terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20, < 3.0"
    }
    helm = {
      # arc-argocd is on the helm provider v2 line, same as 04-eks.
      source  = "hashicorp/helm"
      version = ">= 2.11, < 3.0"
    }
    kubectl = {
      # arc-argocd applies some manifests via the alekc/kubectl provider and
      # requires it to be configured in the root module.
      source  = "alekc/kubectl"
      version = ">= 2.0.0"
    }
    time = {
      # Brief wait so the ArgoCD server has created argocd-initial-admin-secret
      # before we read it for the SSM publish below.
      source  = "hashicorp/time"
      version = ">= 0.9"
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

# Kubernetes/Helm providers wired to the existing 04-eks cluster so the ArgoCD
# module can install its Helm chart onto it.
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}
