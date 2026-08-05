# =============================================================================
# 10-argocd - General Compliance Profile
# =============================================================================
# Single-replica ArgoCD, built-in admin user enabled — suitable for non-prod.
# =============================================================================

namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

enable_argocd        = true
argocd_namespace     = "argocd"
argocd_chart_version = "7.8.13"

ha_enabled         = false
disable_admin_user = false
