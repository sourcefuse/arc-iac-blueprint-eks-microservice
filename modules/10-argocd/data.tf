# Target EKS cluster provisioned by 04-eks. Used to wire the kubernetes/helm
# providers and to tell the ArgoCD module which existing cluster to install on.
data "aws_eks_cluster" "this" {
  name = "${var.namespace}-${var.environment}-eks"
}

data "aws_eks_cluster_auth" "this" {
  name = "${var.namespace}-${var.environment}-eks"
}
