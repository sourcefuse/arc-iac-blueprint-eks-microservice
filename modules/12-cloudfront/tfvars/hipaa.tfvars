# =============================================================================
# 12-cloudfront - HIPAA Compliance Profile
# =============================================================================
# Designed for HIPAA-regulated workloads containing PHI.
#
# Compliance controls enabled:
#   - PriceClass_All (global edge distribution for PHI availability)
#   - Minimum viewer TLS 1.2 via TLSv1.2_2021 policy (strong ciphers only)
#   - HTTPS redirect enforced (viewer_protocol_policy = redirect-to-https)
#   - Access logging enabled — CloudFront request logs stored in the S3 bucket
#     from 05-s3 for audit trail
#
# Note: minimum_protocol_version only takes effect on custom domains using an
# ACM certificate; it is ignored on the default *.cloudfront.net certificate.
#
# Reference: HIPAA Security Rule 45 CFR 164.312(e) - Transmission Security

namespace          = "eb"
environment        = "prod"
compliance_profile = "hipaa"

enable_access_logging = true
price_class           = "PriceClass_All"