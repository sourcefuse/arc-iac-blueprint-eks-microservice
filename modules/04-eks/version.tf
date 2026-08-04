terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      # arc-eks 6.0.5 requires aws >= 6.0.
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20, < 3.0"
    }
    helm = {
      # v2 line: the provider below uses the nested `kubernetes { }` block.
      source  = "hashicorp/helm"
      version = ">= 2.9, < 3.0"
    }
    kubectl = {
      # Applies the Auto Mode IngressClass / gp3 SC / Karpenter CRs.
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    time = {
      # time_sleep gate: lets the EKS access entry propagate before add-ons apply.
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

# Kubernetes/Helm/kubectl providers wired to the cluster module.eks created, so
# the add-ons install onto it in the same apply. The data sources depend_on
# module.eks, so these resolve after the cluster exists.
# kubernetes/helm/kubectl providers wired to the cluster module.eks creates, per
# the official arc-eks auto-mode example. The data sources are keyed by
# module.eks.eks_cluster_id (no depends_on), so these resolve after the cluster
# without forming a cycle with arc-eks's internal (count=0) aws_auth/karpenter.
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
