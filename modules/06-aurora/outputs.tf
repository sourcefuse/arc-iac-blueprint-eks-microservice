output "cluster_endpoint" {
  description = "Writer endpoint (DNS) of the Aurora cluster."
  value       = module.aurora.endpoint
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster."
  value       = module.aurora.arn
}

output "cluster_id" {
  description = "Identifier of the Aurora cluster."
  value       = module.aurora.id
}

output "port" {
  description = "Port the Aurora cluster listens on."
  value       = module.aurora.port
}

output "master_user_secret" {
  description = "Secrets Manager secret holding the managed master credentials."
  value       = module.aurora.master_user_secret
  sensitive   = true
}
