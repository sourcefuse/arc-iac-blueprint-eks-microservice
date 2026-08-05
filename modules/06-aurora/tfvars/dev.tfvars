# =============================================================================
# 06-aurora - Development (general profile)
# =============================================================================
# Tolerant defaults for non-regulated workloads: short 7-day PITR window and
# no deletion protection so dev clusters can be torn down freely.
# =============================================================================

namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

backup_retention    = 7
deletion_protection = false
skip_final_snapshot = true

# Smallest broadly-supported Aurora PostgreSQL burstable class, to keep dev cost
# low (prod/compliance profiles keep the larger r6g class).
instance_class = "db.t3.medium"
