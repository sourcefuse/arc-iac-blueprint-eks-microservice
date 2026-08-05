# Look up the platform VPC provisioned by the 01-network layer by its Name tag.
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

# Private subnets in the platform VPC where EKS nodes are deployed.
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

# The cluster module.eks just created — keyed by its eks_cluster_id OUTPUT (the
# official arc-eks example pattern). This creates the dependency on the cluster
# resource ONLY (not module.eks's internal aws_auth/karpenter resources), so the
# kubernetes/helm/kubectl providers wired from it do NOT form a cycle with the
# module. Do NOT add depends_on = [module.eks] here — that reintroduces the cycle.
data "aws_eks_cluster" "this" {
  name = module.eks.eks_cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.eks_cluster_id
}

# IAM OIDC provider for the cluster (module.eks enable_oidc_provider defaults
# true). Used for the IRSA roles the add-ons attach to their service accounts.
data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}
