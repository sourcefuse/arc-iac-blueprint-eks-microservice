output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.eks_cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint."
  value       = module.eks.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the EKS cluster."
  value       = module.eks.certificate_authority_data
}

output "oidc_provider_url" {
  description = "URL of the EKS OIDC provider for IRSA."
  value       = module.eks.oidc_provider_url
}
