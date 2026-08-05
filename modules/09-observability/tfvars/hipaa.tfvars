# =============================================================================
# 09-observability - HIPAA Compliance Profile
# =============================================================================
# Production-grade metrics platform:
#  - HA: replicated Prometheus + Alertmanager + Grafana so a node loss does not
#    blind the platform.
#  - Long metric retention (90d) to support audit / incident review windows.
#  - Larger, dedicated Prometheus TSDB volume and production resource sizing.
#  - Metrics-only by design: pod/audit logs ship to CloudWatch Logs via
#    aws-for-fluentbit (04-eks), which is encrypted and retained there.
#    No self-managed Elasticsearch and no second Fluent Bit.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "hipaa"

enable_metrics     = true
metrics_namespace  = "metrics"
prometheus_storage = "50Gi"
retention_period   = "90d"

prometheus_replicas   = 2
grafana_replicas      = 2
alertmanager_replicas = 3

prometheus_resources = {
  cpu_request    = "500m"
  cpu_limit      = "2000m"
  memory_request = "2Gi"
  memory_limit   = "4Gi"
}

grafana_resources = {
  cpu_request    = "250m"
  cpu_limit      = "1000m"
  memory_request = "512Mi"
  memory_limit   = "1Gi"
}
