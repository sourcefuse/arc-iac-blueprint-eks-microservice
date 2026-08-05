# =============================================================================
# 06-aurora - PCI-DSS Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - backup_retention = 35 — supports PCI DSS Req 10.5.1 retention of
#     audit-trail history and general data-recovery obligations for the
#     cardholder-data environment.
#   - deletion_protection = true — guards against accidental/malicious loss of
#     cardholder data, aligned with PCI DSS Req 9/12 asset-protection controls.
#   - skip_final_snapshot = false — a final snapshot is always captured on
#     deletion so cardholder data remains recoverable.
#   - kms_deletion_window_in_days = 30 — maximum key-deletion waiting period
#     supports PCI DSS Req 3.6 secure key-management lifecycle controls.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

backup_retention            = 35
deletion_protection         = true
skip_final_snapshot         = false
kms_deletion_window_in_days = 30
