# =============================================================================
# 08-waf - PCI-DSS Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - waf_rate_limit = 1000 — the strictest per-IP request ceiling of the
#     three profiles, supporting PCI DSS Req 6.4.2 (deploy a WAF in front of
#     public-facing web applications) by aggressively throttling automated
#     attacks against the cardholder-data environment's ingress.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

waf_rate_limit = 1000

