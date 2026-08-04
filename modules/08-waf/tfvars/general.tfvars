# =============================================================================
# 08-waf - General Compliance Profile
# =============================================================================
# Standard per-IP rate limit of 5000 requests per 5 minutes — permissive
# enough for typical non-regulated public traffic while still blocking
# obvious abuse. AWS common managed rule set is always enabled.
# =============================================================================

namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

waf_rate_limit = 5000

