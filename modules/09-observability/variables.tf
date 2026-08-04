variable "namespace" {
  description = "Namespace prefix for all resource names (e.g. 'eb')."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. 'dev', 'staging', 'prod')."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "compliance_profile" {
  description = "Compliance profile: 'general', 'hipaa', or 'pci_dss'."
  type        = string
  default     = "general"

  validation {
    condition     = contains(["general", "hipaa", "pci_dss"], var.compliance_profile)
    error_message = "compliance_profile must be one of: general, hipaa, pci_dss."
  }
}

# ---------------------------------------------------------------------------
# Observability toggles. Metrics only — pod logs go to CloudWatch via
# aws-for-fluentbit (04-eks), so the module's EFK log/tracing paths stay off.
# ---------------------------------------------------------------------------
variable "enable_metrics" {
  description = "Master switch for this layer. false = install nothing (no metrics backend)."
  type        = bool
  default     = true
}

# Which metrics/observability backend to run. Both code paths are kept — flip
# this toggle to switch:
#   "prometheus" (default) -> Prometheus + Grafana + Alertmanager (kube-prometheus-stack)
#   "signoz"               -> SigNoz CE all-in-one (ClickHouse + UI + OTEL collector)
# They are mutually exclusive (running both would double the metrics pipeline).
variable "observability_backend" {
  description = "Metrics backend: 'prometheus' (Prometheus+Grafana) or 'signoz' (SigNoz CE all-in-one)."
  type        = string
  default     = "prometheus"
  validation {
    condition     = contains(["prometheus", "signoz"], var.observability_backend)
    error_message = "observability_backend must be 'prometheus' or 'signoz'."
  }
}

# ---- SigNoz options (used only when observability_backend = "signoz") --------
variable "signoz_namespace" {
  description = "Kubernetes namespace for the SigNoz stack."
  type        = string
  default     = "signoz"
}

variable "signoz_storage" {
  description = "ClickHouse (SigNoz datastore) PersistentVolume size."
  type        = string
  default     = "20Gi"
}

variable "signoz_expose_ui" {
  description = "Expose the SigNoz UI via an Ingress on the shared ALB. false = internal (port-forward)."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Dashboard UI ingress (module-owned; joins the shared ALB via the IngressClass).
# Hosts + cert + zone are supplied by the pipeline's observability job.
# ---------------------------------------------------------------------------
variable "signoz_host" {
  description = "Hostname for the SigNoz UI Ingress (e.g. ekssg.example.com). Empty => a non-routable default."
  type        = string
  default     = ""
}

variable "grafana_expose_ui" {
  description = "Expose the Grafana UI via an Ingress on the shared ALB (prometheus backend)."
  type        = bool
  default     = false
}

variable "grafana_host" {
  description = "Hostname for the Grafana UI Ingress (e.g. eksgf.example.com). Empty => ingress disabled."
  type        = string
  default     = ""
}

variable "dashboard_cert_arn" {
  description = "ACM certificate ARN for the dashboard UIs (HTTPS). Empty => HTTP only."
  type        = string
  default     = ""
}

variable "metrics_namespace" {
  description = "Kubernetes namespace for the Prometheus/Grafana stack."
  type        = string
  default     = "metrics"
}

variable "storage_class" {
  description = "StorageClass for the Prometheus PersistentVolume. Leave null to auto-pick: 'gp3' under EKS Auto Mode, 'gp2' under classic EKS."
  type        = string
  default     = null
}

variable "prometheus_storage" {
  description = "PersistentVolume size for Prometheus TSDB."
  type        = string
  default     = "8Gi"
}

variable "retention_period" {
  description = "How long Prometheus keeps metrics (e.g. '15d', '30d', '90d')."
  type        = string
  default     = "15d"
}

# ---------------------------------------------------------------------------
# High-availability / capacity knobs. dev keeps single replicas; hipaa/pci
# profiles run replicated components sized for production.
# ---------------------------------------------------------------------------
variable "prometheus_replicas" {
  description = "Number of Prometheus server replicas."
  type        = number
  default     = 1
}

variable "grafana_replicas" {
  description = "Number of Grafana replicas."
  type        = number
  default     = 1
}

variable "alertmanager_replicas" {
  description = "Number of Alertmanager replicas."
  type        = number
  default     = 1
}

variable "prometheus_resources" {
  description = "CPU/memory requests and limits for the Prometheus server."
  type = object({
    cpu_request    = string
    cpu_limit      = string
    memory_request = string
    memory_limit   = string
  })
  default = {
    cpu_request    = "100m"
    cpu_limit      = "500m"
    memory_request = "256Mi"
    memory_limit   = "1Gi"
  }
}

variable "grafana_resources" {
  description = "CPU/memory requests and limits for Grafana."
  type = object({
    cpu_request    = string
    cpu_limit      = string
    memory_request = string
    memory_limit   = string
  })
  default = {
    cpu_request    = "100m"
    cpu_limit      = "250m"
    memory_request = "128Mi"
    memory_limit   = "256Mi"
  }
}
