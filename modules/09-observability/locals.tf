locals {
  name_prefix = "${var.namespace}-${var.environment}"
  tags        = module.tags.tags

  # Auto Mode ships a default gp3 StorageClass (created by the 04-eks layer);
  # classic EKS ships gp2. Auto-pick unless the caller pins storage_class.
  auto_mode_enabled       = try(data.aws_eks_cluster.this.compute_config[0].enabled, false)
  effective_storage_class = coalesce(var.storage_class, local.auto_mode_enabled ? "gp3" : "gp2")

  # Backend selection -> the arc-observability-stack enums.
  #   prometheus : metrics_monitoring_system = "prometheus"
  #   signoz     : metrics_monitoring_system = "signoz" AND search_engine =
  #                "signoz-clickhouse" (the latter is what actually stands up the
  #                SigNoz backend; the former only wires the collection agents).
  backend                   = var.enable_metrics ? var.observability_backend : "none"
  metrics_monitoring_system = local.backend == "prometheus" ? "prometheus" : (local.backend == "signoz" ? "signoz" : null)
  search_engine             = local.backend == "signoz" ? "signoz-clickhouse" : null
  cluster_name              = data.aws_eks_cluster.this.id
}
