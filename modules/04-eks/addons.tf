# =============================================================================
# Platform add-ons for the EKS cluster (module.eks above), following the
# official arc-eks auto-mode example: kubectl_manifest primitives + raw
# helm_release. aws-6 native (no arc-eks-addon fork, which is pinned to aws < 6).
#
#   Auto Mode  -> LB controller / EBS / autoscaling are BUILT IN. We add only
#                 the Auto Mode primitives below; nothing Helm is installed.
#   Classic    -> those built-ins don't exist, so we install their equivalents
#                 (LB controller / EBS CSI / cluster-autoscaler), gated to !auto.
#
# Optional platform extras (metrics-server, cert-manager, external-secrets,
# fluent-bit, CloudWatch, secrets-store, EFS) are intentionally NOT installed —
# the sample app doesn't need them and Auto Mode stays lean like official arc-eks.
# =============================================================================

# --- EKS Auto Mode primitives (count = 0 in classic) -----------------------
# ALB IngressClass, gp3 StorageClass, Karpenter NodeClass/NodePool. Applied via
# module.eks OUTPUTS (no cluster data-source dependency) to avoid a provider cycle.
# EKS access entries (which grant the CI role cluster-admin) take a short time to
# propagate to the API-server authorizer on a freshly-created cluster. The add-ons
# below apply immediately after module.eks, so without a buffer they can race the
# entry and fail with "forbidden ... at the cluster scope". This gate waits for
# propagation before ANY add-on (Auto Mode primitive or classic Helm release)
# touches the cluster.
resource "time_sleep" "wait_for_access_entry" {
  depends_on      = [module.eks]
  create_duration = "60s"
}

resource "kubectl_manifest" "ingress_class_params" {
  count      = local.auto_mode_enabled ? 1 : 0
  yaml_body  = file("${path.module}/files/ingressclassparams.yaml")
  depends_on = [time_sleep.wait_for_access_entry]
}

resource "kubectl_manifest" "ingress_class" {
  count      = local.auto_mode_enabled ? 1 : 0
  yaml_body  = file("${path.module}/files/ingressclass.yaml")
  depends_on = [kubectl_manifest.ingress_class_params]
}

resource "kubectl_manifest" "storage_class_gp3" {
  count      = local.auto_mode_enabled ? 1 : 0
  yaml_body  = file("${path.module}/files/storageclass-gp3.yaml")
  depends_on = [time_sleep.wait_for_access_entry]
}

resource "kubectl_manifest" "node_class" {
  count = local.auto_mode_enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/files/nodeclass.yaml", {
    name_prefix       = local.name_prefix
    environment       = var.environment
    node_role_name    = element(split("/", module.eks.auto_mode_node_role_arn), 1)
    security_group_id = module.eks.eks_cluster_security_group_id
  })
  depends_on = [time_sleep.wait_for_access_entry]
}

resource "kubectl_manifest" "node_pool" {
  count = local.auto_mode_enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/files/nodepool.yaml", {
    name_prefix = local.name_prefix
    node_class  = "${local.name_prefix}-node-class"
  })
  depends_on = [kubectl_manifest.node_class]
}

# =============================================================================
# CLASSIC-MODE add-ons — count = 0 under Auto Mode (which provides these
# built-in). They make the sample app's Ingress (ALB), PVCs and node
# autoscaling work when enable_auto_mode = false, so BOTH modes work end-to-end.
# =============================================================================

# IRSA roles for the classic add-ons that call AWS APIs. Trust the cluster OIDC
# provider for each add-on's service account. LB controller + cluster-autoscaler
# use CUSTOM policies attached below (empty policy_arns here); EBS CSI uses the
# AWS managed policy in the map.
data "aws_iam_policy_document" "irsa_assume" {
  for_each = local.irsa_service_accounts
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "irsa" {
  for_each           = local.irsa_service_accounts
  name               = "${local.name_prefix}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume[each.key].json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = {
    for pair in flatten([
      for k, v in local.irsa_service_accounts : [
        for arn in v.policy_arns : { key = "${k}:${basename(arn)}", role = k, arn = arn }
      ]
    ]) : pair.key => pair
  }
  role       = aws_iam_role.irsa[each.value.role].name
  policy_arn = each.value.arn
}

# --- AWS Load Balancer Controller (classic) --------------------------------
resource "aws_iam_policy" "lb_controller" {
  count       = local.install_lb_controller ? 1 : 0
  name        = "${local.name_prefix}-alb-controller"
  description = "AWS Load Balancer Controller v2.13 permissions"
  policy      = file("${path.module}/files/lb-controller-iam-policy.json")
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  count      = local.install_lb_controller ? 1 : 0
  role       = aws_iam_role.irsa["aws-load-balancer-controller"].name
  policy_arn = aws_iam_policy.lb_controller[0].arn
}

resource "helm_release" "aws_load_balancer_controller" {
  count      = local.install_lb_controller ? 1 : 0
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.13.4"

  set {
    name  = "clusterName"
    value = module.eks.eks_cluster_id
  }
  set {
    name  = "region"
    value = var.region
  }
  set {
    name  = "vpcId"
    value = data.aws_vpc.this.id
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.irsa["aws-load-balancer-controller"].arn
  }
  # We route via Ingress (ALB), not Service type=LoadBalancer — disabling the
  # service mutating webhook stops it blocking other add-ons' Service creation.
  set {
    name  = "enableServiceMutatorWebhook"
    value = "false"
  }
  # Group ALL "alb"-class Ingresses onto ONE shared ALB at the IngressClass level
  # (the chart creates an IngressClassParams with this group). This mirrors Auto
  # Mode's IngressClassParams `group`, so a single shared ALB works identically in
  # both modes WITHOUT any per-Ingress group.name annotation.
  set {
    name  = "ingressClassParams.spec.group.name"
    value = local.alb_ingress_group
  }
  depends_on = [aws_iam_role_policy_attachment.lb_controller, time_sleep.wait_for_access_entry]
}

# --- EBS CSI driver (classic; Auto Mode ships built-in EBS storage) ---------
resource "helm_release" "aws_ebs_csi_driver" {
  count      = local.install_ebs_csi ? 1 : 0
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = "2.35.1"

  depends_on = [time_sleep.wait_for_access_entry]

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.irsa["ebs-csi-controller-sa"].arn
  }
}

# --- Cluster Autoscaler (classic; Auto Mode's built-in Karpenter scales) ----
resource "aws_iam_policy" "cluster_autoscaler" {
  count       = local.install_cluster_autoscaler ? 1 : 0
  name        = "${local.name_prefix}-cluster-autoscaler"
  description = "Cluster Autoscaler permissions"
  tags        = local.tags
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup",
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count      = local.install_cluster_autoscaler ? 1 : 0
  role       = aws_iam_role.irsa["cluster-autoscaler"].name
  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
}

resource "helm_release" "cluster_autoscaler" {
  count      = local.install_cluster_autoscaler ? 1 : 0
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.43.2"

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.eks_cluster_id
  }
  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.irsa["cluster-autoscaler"].arn
  }
  depends_on = [aws_iam_role_policy_attachment.cluster_autoscaler, time_sleep.wait_for_access_entry]
}
