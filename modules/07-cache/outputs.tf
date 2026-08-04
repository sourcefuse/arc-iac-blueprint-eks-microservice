output "cluster_address" {
  description = "ElastiCache Redis primary endpoint address."
  # arc-cache returns this as a list; expose a single string so `terraform
  # output -raw cluster_address` works for consumers (e.g. the deploy workflow).
  value = try(module.cache.primary_endpoint_address[0], module.cache.primary_endpoint_address)
}

output "reader_endpoint_address" {
  description = "ElastiCache Redis reader endpoint address."
  value       = module.cache.reader_endpoint_address
}

output "cluster_id" {
  description = "ElastiCache Redis replication group ID."
  value       = module.cache.id
}

output "security_group_id" {
  description = "Security group ID created for the Redis cluster."
  value       = module.cache.security_group_id
}
