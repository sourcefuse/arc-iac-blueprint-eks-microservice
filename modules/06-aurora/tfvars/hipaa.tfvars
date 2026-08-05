# =============================================================================
# 06-aurora - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - backup_retention = 35 — extended point-in-time-recovery window satisfies
#     HIPAA 45 CFR 164.308(a)(7)(ii)(A), which requires a data backup plan
#     capable of restoring ePHI.
#   - deletion_protection = true — prevents accidental/malicious destruction of
#     the cluster holding ePHI, supporting the 164.308(a)(7) contingency plan.
#   - skip_final_snapshot = false — a final snapshot is always captured on
#     deletion so ePHI remains recoverable.
#   - kms_deletion_window_in_days = 30 — maximum key-deletion waiting period
#     provides the widest window to reverse an erroneous key deletion, aligned
#     with 164.312(a)(2)(iv) encryption/key-management controls.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "hipaa"

backup_retention            = 35
deletion_protection         = true
skip_final_snapshot         = false
kms_deletion_window_in_days = 30
