# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "10-argocd"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# ArgoCD (GitOps continuous delivery) installed onto the EXISTING 04-eks
# cluster. Uses the dedicated ARC ArgoCD module instead of the ArgoCD add-on
# bundled in 04-eks, so CD gets its own release cadence and first-class
# knobs (projects, applications, repositories, SSO, image-updater, HA).
#
# The ArgoCD UI is exposed publicly through the SHARED ALB by the pipeline's
# expose-dashboards job (host-based routing at https://eksargocd.<zone>), so the
# module's own ingress is disabled here — keeping one ALB and the eksargocd
# subdomain exactly as before.
module "argocd" {
  source  = "sourcefuse/arc-argocd/aws"
  version = "0.0.3"

  namespace        = var.namespace
  environment      = var.environment
  eks_cluster_name = data.aws_eks_cluster.this.name

  argocd_config = {
    enable           = var.enable_argocd
    namespace        = var.argocd_namespace
    create_namespace = true
    version          = var.argocd_chart_version
  }

  # HA: replicate the control-plane components in production profiles.
  ha_config = {
    enable               = var.ha_enabled
    server_replicas      = var.server_replicas
    repo_server_replicas = var.repo_server_replicas
    controller_replicas  = var.controller_replicas
  }

  # Disable the built-in admin user in production once SSO is wired.
  admin_config = {
    disable_admin = var.disable_admin_user
  }

  # ArgoCD UI Ingress on the SHARED ALB (host-based routing). The IngressGroup is
  # set at the IngressClass level (04-eks) in both compute modes, so no per-Ingress
  # group.name annotation is needed. The module also creates the Route53 record.
  ingress_config = {
    enable              = var.expose_argocd && var.argocd_host != ""
    host                = var.argocd_host
    ingress_class_name  = "alb"
    tls_enabled         = var.argocd_cert_arn != ""
    acm_certificate_arn = var.argocd_cert_arn
    # DNS is created by the pipeline (dashboards-dns) AFTER the ALB is up. The
    # module's auto record races ALB provisioning (reads an empty hostname in the
    # same apply -> "expected length of alias.0.name ... got ").
    auto_create_route53_record = false
    route53_zone_name          = ""
    annotations = {
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
    }
  }

  # -------------------------------------------------------------------------
  # GitOps delivery of the sample app. Both maps are empty during the
  # control-plane apply (app_image unset) and populated during the app apply
  # (deploy-sample), so ArgoCD only starts managing the app once an image is
  # built. See locals.tf and variables.tf (app_*).
  # -------------------------------------------------------------------------

  # Repository credential so ArgoCD can pull the (private) chart repo over HTTPS.
  repositories = local.create_sample_app && var.app_repo_password != "" ? {
    (var.app_name) = {
      url      = var.app_repo_url
      type     = "git"
      username = var.app_repo_username
      password = var.app_repo_password
    }
  } : {}

  # The Application: ArgoCD renders charts/sample-app with the pipeline-supplied
  # Helm parameters and reconciles it (auto-sync + self-heal; CreateNamespace).
  applications = local.create_sample_app ? {
    (var.app_name) = {
      project         = "default"
      repo_url        = var.app_repo_url
      target_revision = var.app_target_revision
      path            = var.app_chart_path
      helm = {
        release_name = var.app_name
        parameters   = local.sample_app_params
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.app_namespace
      }
      sync_policy = {
        automated    = { prune = true, self_heal = true }
        sync_options = ["CreateNamespace=true"]
        retry = {
          limit   = 5
          backoff = { duration = "5s", factor = 2, max_duration = "3m" }
        }
      }
    }
  } : {}

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Publish the ArgoCD admin credentials to SSM Parameter Store, mirroring how the
# observability module stores Grafana creds (/<ns>/<env>/grafana/<name>/creds).
# Operators fetch the password from Parameter Store instead of kubectl-ing the
# bootstrap secret:
#   aws ssm get-parameter --with-decryption \
#     --name /eb/dev/argocd/admin/creds --query Parameter.Value --output text
# ---------------------------------------------------------------------------
# ArgoCD server writes argocd-initial-admin-secret during startup; give it a
# moment after the Helm release settles before reading it.
resource "time_sleep" "argocd_admin_secret" {
  count           = var.enable_argocd ? 1 : 0
  create_duration = "60s"
  depends_on      = [module.argocd]
}

data "kubernetes_secret" "argocd_admin" {
  count = var.enable_argocd ? 1 : 0

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argocd_namespace
  }

  depends_on = [time_sleep.argocd_admin_secret]
}

resource "aws_ssm_parameter" "argocd_admin_creds" {
  count       = var.enable_argocd ? 1 : 0
  name        = "/${var.namespace}/${var.environment}/argocd/admin/creds"
  description = "ArgoCD admin credentials (initial admin user)."
  type        = "SecureString"
  value = jsonencode({
    user = "admin"
    # Null-tolerant: on a fresh install (or if the namespace was reset) the
    # initial-admin-secret may not be readable at plan time; don't crash the plan.
    # It's re-read at apply once ArgoCD is up (after time_sleep.argocd_admin_secret).
    password = try(data.kubernetes_secret.argocd_admin[0].data["password"], "")
  })
  tags = local.tags
}
