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

# ---------------------------------------------------------------------------
# ArgoCD toggles. This layer replaces the ArgoCD add-on that 04-eks used
# to bundle: GitOps continuous delivery now lives in its own dedicated,
# separately-versioned layer (arc-argocd).
# ---------------------------------------------------------------------------
variable "enable_argocd" {
  description = "Install ArgoCD (GitOps continuous delivery)."
  type        = bool
  default     = true
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD."
  type        = string
  default     = "argocd"
}

# ---------------------------------------------------------------------------
# ArgoCD UI ingress (module-owned; joins the shared ALB via the IngressClass).
# Supplied by the pipeline (host = eksag.<zone>, cert = wildcard ACM). Must be
# passed on BOTH applies of this layer (control-plane + deploy-sample) so the
# re-apply doesn't drop the ingress.
# ---------------------------------------------------------------------------
variable "expose_argocd" {
  description = "Expose the ArgoCD UI via an Ingress on the shared ALB."
  type        = bool
  default     = false
}

variable "argocd_host" {
  description = "Hostname for the ArgoCD UI Ingress (e.g. eksag.example.com). Empty => ingress disabled."
  type        = string
  default     = ""
}

variable "argocd_cert_arn" {
  description = "ACM certificate ARN for the ArgoCD UI (HTTPS). Empty => HTTP only."
  type        = string
  default     = ""
}

variable "argocd_chart_version" {
  description = "argo-cd Helm chart version."
  type        = string
  default     = "7.8.13"
}

# ---------------------------------------------------------------------------
# High availability. dev runs the single-replica default; hipaa/pci run the
# ArgoCD control-plane components replicated so a node loss doesn't stop syncs.
# ---------------------------------------------------------------------------
variable "ha_enabled" {
  description = "Run ArgoCD in HA mode (replicated server / repo-server / application controller)."
  type        = bool
  default     = false
}

variable "server_replicas" {
  description = "ArgoCD API server replicas (HA mode)."
  type        = number
  default     = 2
}

variable "repo_server_replicas" {
  description = "ArgoCD repo-server replicas (HA mode)."
  type        = number
  default     = 2
}

variable "controller_replicas" {
  description = "ArgoCD application-controller replicas (HA mode)."
  type        = number
  default     = 1
}

# ---------------------------------------------------------------------------
# Admin hardening. The built-in local `admin` user is convenient for dev but
# should be disabled in production ONCE SSO is wired (sso_config), otherwise you
# lock yourself out. Left enabled by default; flip on per environment after SSO.
# ---------------------------------------------------------------------------
variable "disable_admin_user" {
  description = "Disable the built-in ArgoCD admin user (only after SSO is configured)."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Sample-app GitOps delivery. When enabled AND an image is supplied, this layer
# declares an ArgoCD Application that syncs the Helm chart at charts/sample-app
# from this repo — so the app is deployed BY ArgoCD (auto-sync + self-heal) and
# shows up as a first-class Application in the ArgoCD UI, instead of being
# `helm install`-ed by the pipeline. The pipeline (create.yml deploy-sample)
# re-applies this layer with the freshly built image tag + the resolved
# backing-service endpoints as Helm parameters on each deploy.
# ---------------------------------------------------------------------------
variable "enable_sample_app" {
  description = "Declare the ArgoCD Application for the sample app (only takes effect once app_image is set)."
  type        = bool
  default     = true
}

variable "app_name" {
  description = "ArgoCD Application name / Helm release name for the sample app."
  type        = string
  default     = "sample-app"
}

variable "app_namespace" {
  description = "Namespace ArgoCD deploys the sample app into (created via CreateNamespace sync option)."
  type        = string
  default     = "sample-app"
}

variable "app_repo_url" {
  description = "HTTPS URL of the Git repo ArgoCD pulls the chart from. Must match the repository credential's url."
  type        = string
  default     = ""
}

variable "app_target_revision" {
  description = "Git revision (branch/tag/SHA) ArgoCD tracks for the sample app."
  type        = string
  default     = "main"
}

variable "app_chart_path" {
  description = "Path to the sample-app Helm chart within the repo."
  type        = string
  default     = "charts/sample-app"
}

variable "app_image" {
  description = "Full image ref '<repo>:<tag>' for the sample app (from build-sample). Empty => the Application is NOT created."
  type        = string
  default     = ""
}

variable "app_db_host" {
  description = "Aurora endpoint injected as the chart's env.dbHost Helm parameter."
  type        = string
  default     = ""
}

variable "app_redis_host" {
  description = "ElastiCache address injected as the chart's env.redisHost Helm parameter."
  type        = string
  default     = ""
}

variable "app_cert_arn" {
  description = "ACM certificate ARN for the app Ingress (HTTPS). Empty => the chart serves plain HTTP."
  type        = string
  default     = ""
}

variable "app_host" {
  description = "Custom hostname for the app Ingress (e.g. eksbp.arc-poc.link). Empty => raw ALB DNS."
  type        = string
  default     = ""
}

variable "app_repo_username" {
  description = "Username for the ArgoCD Git repository credential (HTTPS basic auth)."
  type        = string
  default     = ""
}

variable "app_repo_password" {
  description = "Password/token (PAT) for the ArgoCD Git repository credential (HTTPS basic auth)."
  type        = string
  default     = ""
  sensitive   = true
}
