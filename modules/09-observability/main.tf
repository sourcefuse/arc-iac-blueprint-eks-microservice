# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "09-observability"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# Metrics stack on the existing 04-eks cluster (arc-observability-stack).
# Published SourceFuse ARC module (the grafana-lb-dns-output fix is merged upstream).
#
# Logs/tracing stay off: pod logs go to CloudWatch via aws-for-fluentbit (04-eks).
# Grafana's ingress is off; the pipeline exposes it on the shared ALB.
module "observability" {
  source  = "sourcefuse/arc-observability-stack/aws"
  version = "1.0.3"

  namespace   = var.namespace
  environment = var.environment

  # Backend selection (computed in locals.tf from var.observability_backend):
  #   prometheus -> metrics_monitoring_system = "prometheus"
  #   signoz     -> metrics_monitoring_system = "signoz" + search_engine =
  #                 "signoz-clickhouse" (the pair that stands up SigNoz).
  # log_aggregator / tracing_stack stay disabled — pod logs ship to CloudWatch
  # via aws-for-fluentbit (04-eks).
  metrics_monitoring_system = local.metrics_monitoring_system
  search_engine             = local.search_engine

  prometheus_config = {
    name             = "prometheus"
    storage          = var.prometheus_storage
    storage_class    = local.effective_storage_class
    retention_period = var.retention_period
    replica_count    = var.prometheus_replicas

    cpu_request    = var.prometheus_resources.cpu_request
    cpu_limit      = var.prometheus_resources.cpu_limit
    memory_request = var.prometheus_resources.memory_request
    memory_limit   = var.prometheus_resources.memory_limit

    k8s_namespace = {
      name   = var.metrics_namespace
      create = true
    }

    grafana_config = {
      # Grafana UI Ingress on the SHARED ALB (host-based routing). Grouping is at
      # the IngressClass level (04-eks), so no per-Ingress group.name is needed.
      ingress_enabled     = var.grafana_expose_ui && var.grafana_host != ""
      ingress_host        = var.grafana_host
      aws_certificate_arn = var.dashboard_cert_arn
      lb_visibility       = "internet-facing"
      admin_user          = "admin"
      replica_count       = var.grafana_replicas
      cpu_request         = var.grafana_resources.cpu_request
      cpu_limit           = var.grafana_resources.cpu_limit
      memory_request      = var.grafana_resources.memory_request
      memory_limit        = var.grafana_resources.memory_limit
    }

    blackbox_exporter_config = {
      monitoring_targets = []
    }

    alertmanager_config = {
      replica_count = var.alertmanager_replicas
    }
  }

  # SigNoz CE all-in-one (used only when observability_backend = "signoz"). Kept
  # populated for both backends so the module can evaluate it; it only stands up
  # when search_engine = "signoz-clickhouse". storage_class auto-picks gp3/gp2
  # like Prometheus. UI is internal unless signoz_expose_ui = true.
  signoz_config = {
    name          = "signoz"
    cluster_name  = local.cluster_name
    storage_class = local.effective_storage_class
    k8s_namespace = {
      name   = var.signoz_namespace
      create = true
    }
    clickhouse = {
      storage = var.signoz_storage
    }
    signoz_bin = {
      # SigNoz UI Ingress on the SHARED ALB. Grouping is at the IngressClass level
      # (04-eks). root_domain (when set) makes the module create the DNS record.
      ingress_enabled = var.signoz_expose_ui
      lb_visibility   = "internet-facing"
      domain          = var.signoz_host != "" ? var.signoz_host : "signoz.${local.name_prefix}.local"
      # DNS is created by the pipeline (dashboards-dns) after the ALB is up;
      # the module's root_domain record races ALB provisioning like arc-argocd.
      root_domain = null
      # Non-null even when disabled (the chart always renders the cert-arn annotation).
      aws_certificate_arn = var.dashboard_cert_arn
    }
    # The SigNoz chart template interpolates these OTEL collector resource values
    # unconditionally, so the object must be present (these are its defaults).
    otel_collector = {
      cpu_request    = "100m"
      memory_request = "200Mi"
      cpu_limit      = "1"
      memory_limit   = "2Gi"
    }
    # Must be non-null: the template guard `if alertmanager != null &&
    # alertmanager.enable` does NOT short-circuit in Terraform, so it dereferences
    # alertmanager.enable even when the object is null. enable=false keeps the
    # SigNoz Alertmanager off (guard evaluates false -> chart sets enabled: false).
    alertmanager = {
      enable = false
    }
  }

  # Metrics/logs collection agents (signoz-infra sub-module). Required whenever
  # metrics_monitoring_system = "signoz": it ships node/pod metrics to the SigNoz
  # OTEL collector deployed by signoz_config above. The namespace is created there
  # (create = false here to avoid a duplicate). otel_collector_endpoint is left
  # unset so the module derives the in-cluster collector Service DNS. Logs stay
  # off — pod logs ship to CloudWatch via aws-for-fluentbit (04-eks).
  signoz_infra_monitor_config = {
    name          = "signoz"
    cluster_name  = local.cluster_name
    storage_class = local.effective_storage_class
    k8s_namespace = {
      name   = var.signoz_namespace
      create = false
    }
    enable_metrics_collection  = true
    enable_log_collection      = false
    metric_collection_interval = "30s"
  }

  tags = local.tags
}
