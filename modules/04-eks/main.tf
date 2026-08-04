# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "04-eks"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# Provisions the EKS cluster, OIDC provider, and managed node groups.
module "eks" {
  source  = "sourcefuse/arc-eks/aws"
  version = "6.0.5"

  name        = "${local.name_prefix}-eks"
  namespace   = var.namespace
  environment = var.environment

  kubernetes_version = var.kubernetes_version

  # Allow the private API server (443) to be reached from anywhere in the VPC —
  # i.e. the ephemeral self-hosted runner the pipeline launches in a private
  # subnet. Without this the runner can't kubectl/helm into the private endpoint.
  additional_cluster_security_group_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.this.cidr_block]
      description = "Kubernetes API from within the VPC (self-hosted runner)"
    }
  ]

  # Private-only API server (reachable only inside the VPC). The pipeline must
  # run from a self-hosted runner in this VPC — see the access entry below.
  vpc_config = {
    subnet_ids              = data.aws_subnets.private.ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  # Grant the CI/OIDC deploy role cluster-admin (EKS access entry) so the
  # pipeline can install add-ons and kubectl-apply the sample app.
  access_config = {
    authentication_mode = "API"
    eks_access_entries = concat(
      var.ci_admin_role_arn == "" ? [] : [
        {
          principal_arn = var.ci_admin_role_arn
          policy_arns   = ["arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"]
          access_scope  = { type = "cluster" }
        }
      ],
      [
        for arn in var.admin_access_role_arns : {
          principal_arn = arn
          policy_arns   = ["arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"]
          access_scope  = { type = "cluster" }
        }
      ],
    )
  }

  # Envelope-encrypt Kubernetes secrets with a module-managed KMS key (the
  # external-key path hits an arc-eks bug, so we let the module create the key).
  envelope_encryption = {
    enable    = true
    resources = ["secrets"]
  }

  # Control-plane logging to CloudWatch. Off for general/dev; the hipaa/pci
  # profiles enable the full set (esp. `audit`/`authenticator`) for an API-server
  # audit trail. Logs land in /aws/eks/<cluster>/cluster; retention is the AWS
  # default (never-expire), which satisfies >= 1-year retention requirements.
  enabled_cluster_log_types = var.enabled_cluster_log_types

  # Compute model (var.enable_auto_mode): true = EKS Auto Mode (AWS-managed
  # nodes, built-in Karpenter); false = the classic node group below.
  auto_mode_config = {
    enable     = var.enable_auto_mode
    node_pools = var.auto_mode_node_pools
  }

  # Auto Mode requires this false (AWS manages core add-ons); classic keeps it
  # true so EKS bootstraps kube-proxy/coredns/vpc-cni.
  bootstrap_self_managed_addons_enabled = !var.enable_auto_mode

  node_group_config = {
    enable = !var.enable_auto_mode
    config = var.enable_auto_mode ? {} : {
      platform = {
        instance_types = var.node_instance_types
        disk_size      = 50
        subnet_ids     = data.aws_subnets.private.ids
        scaling_config = {
          desired_size = var.node_desired_size
          min_size     = var.node_min_size
          max_size     = var.node_max_size
        }
      }
    }
  }

  tags = local.tags
}
