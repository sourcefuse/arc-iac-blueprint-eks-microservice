# Namespace + service the pipeline's expose-dashboards job targets when it wires
# the shared-ALB Ingress for Grafana. Service name follows the kube-prometheus-
# stack convention "<release>-grafana" (release = "prometheus").
output "grafana_namespace" {
  description = "Kubernetes namespace the Grafana service runs in."
  value       = var.metrics_namespace
}

output "grafana_service" {
  description = "Kubernetes Service name for Grafana (kube-prometheus-stack convention)."
  value       = "prometheus-grafana"
}

output "grafana_lb_dns" {
  description = "Grafana ingress load balancer DNS (empty — Grafana is exposed via the shared ALB by the pipeline)."
  value       = try(module.observability.grafana_lb_dns, "")
}

# --- SigNoz (populated only when observability_backend = "signoz") -----------
output "observability_backend" {
  description = "Active metrics backend: 'prometheus' or 'signoz'."
  value       = var.observability_backend
}

output "signoz_lb_dns" {
  description = "SigNoz UI ingress LB DNS (null unless observability_backend=signoz AND signoz_expose_ui=true)."
  value       = try(module.observability.signoz_lb_dns, null)
}
