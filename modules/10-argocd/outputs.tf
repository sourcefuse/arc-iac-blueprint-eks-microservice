output "argocd_namespace" {
  description = "Kubernetes namespace ArgoCD is installed in."
  value       = var.argocd_namespace
}

output "argocd_server_url" {
  description = "ArgoCD server URL (cluster-internal unless an ingress host is set)."
  value       = try(module.argocd.argocd_server_url, "")
}

output "chart_version" {
  description = "Deployed argo-cd Helm chart version."
  value       = try(module.argocd.chart_version, var.argocd_chart_version)
}
