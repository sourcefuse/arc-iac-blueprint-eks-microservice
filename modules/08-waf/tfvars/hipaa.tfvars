# =============================================================================
# 08-waf - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - waf_rate_limit = 2000 — a tighter per-IP request ceiling reduces the
#     attack surface for brute-force/credential-stuffing attempts against
#     endpoints that may expose ePHI, supporting HIPAA's 45 CFR
#     164.312(c) integrity and 164.312(e) transmission-security safeguards.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "hipaa"

waf_rate_limit = 2000

