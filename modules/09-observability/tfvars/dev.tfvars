namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

enable_metrics = true

# Metrics backend — flip to switch stacks (mutually exclusive):
#   "prometheus" = Prometheus + Grafana + Alertmanager
#   "signoz"     = SigNoz CE (ClickHouse + UI + OTEL collector)
observability_backend = "signoz"

metrics_namespace  = "metrics"
prometheus_storage = "8Gi"

# SigNoz options (used only when observability_backend = "signoz"):
# signoz_storage   = "20Gi"
# signoz_expose_ui = false   # true = give the SigNoz UI its own ALB

# storage_class auto-picks gp3 (Auto Mode) / gp2 (classic) when left unset.
