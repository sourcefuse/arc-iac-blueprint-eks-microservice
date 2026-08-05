locals {
  name_prefix = "${var.namespace}-${var.environment}"
  tags        = module.tags.tags

  # OIDC issuer host (no scheme) for building IRSA trust-policy conditions.
  oidc_host = replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")

  # Compute model, from var.enable_auto_mode (known at plan time — it gates
  # `count` on the Auto Mode primitive manifests). The Auto Mode node role /
  # cluster security group used by the NodeClass come from module.eks OUTPUTS
  # (see addons.tf), matching the official arc-eks auto-mode example.
  auto_mode_enabled = var.enable_auto_mode

  # IngressGroup name that merges all "alb"-class Ingresses onto ONE shared ALB.
  # Auto Mode sets it in files/ingressclassparams.yaml; classic sets it on the
  # AWS LB Controller (ingressClassParams.spec.group.name). Keep both in sync.
  # 08-waf finds the shared ALB by this value (ingress.*/stack tag).
  alb_ingress_group = "eksblueprint"

  # Classic-mode-only add-ons: Auto Mode provides these built-in (LB controller,
  # EBS storage, node autoscaling), so they install ONLY when auto mode is off.
  install_lb_controller      = !var.enable_auto_mode && var.enable_aws_load_balancer_controller
  install_cluster_autoscaler = !var.enable_auto_mode && var.enable_cluster_autoscaler
  install_ebs_csi            = !var.enable_auto_mode && var.enable_ebs_csi_driver

  # IRSA roles to create for the AWS-integrating add-ons — only when the add-on
  # is enabled. key = role suffix + aws_iam_role.irsa map key referenced in
  # addons.tf; value = the Kubernetes service account to trust + AWS policies.
  # (LB controller + cluster-autoscaler use CUSTOM policies attached separately
  # in addons.tf, so their policy_arns here are empty — the map still creates
  # their role + OIDC trust.)
  irsa_service_accounts = merge(
    local.install_lb_controller ? {
      "aws-load-balancer-controller" = {
        namespace       = "kube-system"
        service_account = "aws-load-balancer-controller"
        policy_arns     = []
      }
    } : {},
    local.install_cluster_autoscaler ? {
      "cluster-autoscaler" = {
        namespace       = "kube-system"
        service_account = "cluster-autoscaler"
        policy_arns     = []
      }
    } : {},
    local.install_ebs_csi ? {
      "ebs-csi-controller-sa" = {
        namespace       = "kube-system"
        service_account = "ebs-csi-controller-sa"
        policy_arns     = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
      }
    } : {},
  )
}
