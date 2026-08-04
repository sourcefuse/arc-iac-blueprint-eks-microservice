output "repository_url" {
  description = "ECR repository URL. Push application container images here."
  value       = module.ecr.repository_urls["${local.name_prefix}-app"]
}

output "repository_urls" {
  description = "Map of all ECR repository names to their URLs."
  value       = module.ecr.repository_urls
}
