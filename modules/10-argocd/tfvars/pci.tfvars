# =============================================================================
# 10-argocd - PCI DSS Compliance Profile
# =============================================================================
# Production-grade GitOps control plane for cardholder-data environments:
#  - HA: replicated API server, repo-server and application controller (no
#    single point of failure for the deployment pipeline).
#  - Built-in admin user stays enabled here because SSO is not wired in the
#    blueprint yet. For PCI DSS: configure sso_config (OIDC/SAML), enforce MFA
#    at the IdP, then set disable_admin_user = true so every change maps to a
#    named identity (Req. 8 unique IDs, Req. 10 audit trail).
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

enable_argocd        = true
argocd_namespace     = "argocd"
argocd_chart_version = "7.8.13"

ha_enabled           = true
server_replicas      = 2
repo_server_replicas = 2
controller_replicas  = 1

# Set to true only AFTER wiring SSO (otherwise you lock yourself out).
disable_admin_user = false
