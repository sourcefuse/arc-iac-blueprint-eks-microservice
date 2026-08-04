# =============================================================================
# 06-aurora - General Compliance Profile
# =============================================================================
# Standard 7-day backup retention window and no deletion protection —
# tolerant defaults for non-regulated workloads where the cost of a longer
# PITR window outweighs the recovery benefit. Final snapshots are skipped so
# clusters can be destroyed without leaving orphaned snapshots behind.
# =============================================================================

namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

backup_retention    = 7
deletion_protection = false
skip_final_snapshot = true
