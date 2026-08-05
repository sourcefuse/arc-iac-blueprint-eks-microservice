# =============================================================================
# 10-argocd - HIPAA Compliance Profile
# =============================================================================
# Production-grade GitOps control plane:
#  - HA: replicated API server, repo-server and application controller so a
#    node loss doesn't halt reconciliation / deployments.
#  - Built-in admin user stays enabled here because SSO is not wired in the
#    blueprint yet. In a real HIPAA deployment: configure sso_config (OIDC/SAML)
#    then set disable_admin_user = true so access is auditable per-identity.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "hipaa"

enable_argocd        = true
argocd_namespace     = "argocd"
argocd_chart_version = "7.8.13"

ha_enabled           = true
server_replicas      = 2
repo_server_replicas = 2
controller_replicas  = 1

# Set to true only AFTER wiring SSO (otherwise you lock yourself out).
disable_admin_user = false
