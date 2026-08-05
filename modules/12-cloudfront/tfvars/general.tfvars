# =============================================================================
# 12-cloudfront - General Compliance Profile
# =============================================================================
# Standard CloudFront distribution settings for non-regulated workloads.
#
# Compliance controls enabled:
#   - PriceClass_All (global edge distribution)
#   - Minimum viewer TLS 1.2 (TLSv1.2_2021) on custom domains
#   - HTTPS redirect enforced by the distribution (viewer_protocol_policy)
#
# For HIPAA/PHI workloads, use: hipaa.tfvars
# For PCI-DSS cardholder data workloads, use: pci.tfvars

namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

enable_access_logging = false
price_class           = "PriceClass_All"
