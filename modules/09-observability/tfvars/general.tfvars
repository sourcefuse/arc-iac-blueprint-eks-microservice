# =============================================================================
# 09-observability - General Compliance Profile
# =============================================================================
# Metrics-only baseline (Prometheus + Grafana). Single replicas, short
# retention — suitable for non-production. Logs stay on CloudWatch (04-eks
# aws-for-fluentbit); this layer never runs a second Fluent Bit.
# =============================================================================

namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

enable_metrics     = true
metrics_namespace  = "metrics"
prometheus_storage = "8Gi"
retention_period   = "15d"

prometheus_replicas   = 1
grafana_replicas      = 1
alertmanager_replicas = 1
