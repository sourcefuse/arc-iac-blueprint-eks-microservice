# =============================================================================
# 09-observability - PCI DSS Compliance Profile
# =============================================================================
# Production-grade metrics platform for cardholder-data environments:
#  - HA: replicated Prometheus + Alertmanager + Grafana (Req. 10 monitoring
#    must not have a single point of failure).
#  - 90d online metric retention (PCI DSS expects at least 3 months of audit
#    history readily available; archive older data downstream as needed).
#  - Larger dedicated TSDB volume + production resource sizing.
#  - Metrics-only by design: logs ship to CloudWatch Logs via aws-for-fluentbit
#    (04-eks). No self-managed Elasticsearch and no second Fluent Bit.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

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
