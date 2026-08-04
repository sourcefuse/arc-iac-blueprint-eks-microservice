variable "namespace" {
  description = "Namespace prefix for all resource names (e.g. 'eb')."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. 'dev', 'staging', 'prod')."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "compliance_profile" {
  description = "Compliance profile: 'general', 'hipaa', or 'pci_dss'."
  type        = string
  default     = "general"

  validation {
    condition     = contains(["general", "hipaa", "pci_dss"], var.compliance_profile)
    error_message = "compliance_profile must be one of: general, hipaa, pci_dss."
  }
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.36"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes."
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "node_desired_size" {
  description = "Desired worker node count."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum worker node count."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum worker node count."
  type        = number
  default     = 10
}

variable "enable_auto_mode" {
  description = <<-EOT
    Compute model for the cluster. false (default) = classic managed node
    groups (node_instance_types / node_*_size). true = EKS Auto Mode, where AWS
    provisions and scales nodes automatically (Karpenter built-in) and the
    managed node group is disabled.
  EOT
  type        = bool
  default     = false
}

variable "auto_mode_node_pools" {
  description = "Auto Mode built-in node pools to enable (only used when enable_auto_mode = true)."
  type        = list(string)
  default     = ["general-purpose", "system"]
}

variable "ci_admin_role_arn" {
  description = <<-EOT
    IAM role ARN (the CI/OIDC deploy role) to grant cluster-admin via an EKS
    access entry, so the pipeline can install the add-ons and kubectl-apply the
    sample app. Passed from the workflow as
    TF_VAR_ci_admin_role_arn = secrets.AWS_ROLE_ARN. Empty = no access entry.
  EOT
  type        = string
  default     = ""
}

variable "admin_access_role_arns" {
  description = <<-EOT
    Additional IAM role ARNs to grant cluster-admin via EKS access entries — e.g.
    the operator/SSO roles that engineers use to reach the private API over the
    VPN. This makes access declarative (survives re-applies), so no manual
    `aws eks create-access-entry` is needed per cluster.

    For AWS SSO (Identity Center) roles, use the underlying role ARN under the
    reserved path, e.g.
      arn:aws:iam::<account>:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_xxxx
  EOT
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# Classic-mode add-on toggles. Under Auto Mode these are BUILT IN, so they only
# install when enable_auto_mode = false. (Auto Mode installs zero Helm add-ons —
# just the IngressClass/gp3/Karpenter primitives, like the official arc-eks.)
# ---------------------------------------------------------------------------
variable "enable_aws_load_balancer_controller" {
  description = "Classic mode: install the AWS Load Balancer Controller (ALB Ingress)."
  type        = bool
  default     = true
}

variable "enable_ebs_csi_driver" {
  description = "Classic mode: install the AWS EBS CSI driver (+ IRSA) for PersistentVolumes."
  type        = bool
  default     = true
}

variable "enable_cluster_autoscaler" {
  description = "Classic mode: install Cluster Autoscaler (scales the managed node group)."
  type        = bool
  default     = true
}

variable "enabled_cluster_log_types" {
  description = <<-EOT
    EKS control-plane log types to ship to CloudWatch. Valid values:
    api, audit, authenticator, controllerManager, scheduler. Empty disables
    control-plane logging (general/dev); the hipaa/pci profiles enable the full
    set for a compliance audit trail.
  EOT
  type        = list(string)
  default     = []
}
