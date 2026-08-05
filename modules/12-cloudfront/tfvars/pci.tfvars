# =============================================================================
# 12-cloudfront - PCI-DSS Compliance Profile
# =============================================================================
# Designed for PCI-DSS cardholder data environments (CDE).
#
# Compliance controls enabled:
#   - Minimum viewer TLS 1.2 via TLSv1.2_2021 policy (PCI DSS v4.0 Req 4.2.1
#     requires strong cryptography; the 2021 policy removes weak cipher suites)
#   - HTTPS redirect enforced (viewer_protocol_policy = redirect-to-https)
#   - Access logging enabled — CloudFront request logs stored in the S3 bucket
#     from 05-s3 for audit trail (PCI DSS v4.0 Req 10)
#
# Cost choice (NOT a compliance control):
#   - PriceClass_200 limits which CloudFront edge locations serve content
#     (drops the most expensive POPs). This is purely a cost/latency trade-off.
#     It does NOT reduce attack surface or define a PCI compliance boundary —
#     CloudFront edge infrastructure is in AWS PCI scope regardless of price
#     class. Set to PriceClass_All if you need global low-latency delivery.
#
# Note: minimum_protocol_version only takes effect on custom domains using an
# ACM certificate; it is ignored on the default *.cloudfront.net certificate.
#
# Reference: PCI DSS v4.0 - Requirement 4.2.1 (Strong cryptography in transit),
#            Requirement 10 (Logging and Monitoring)

namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

enable_access_logging = true
price_class           = "PriceClass_200"