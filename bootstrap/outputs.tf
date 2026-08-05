output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state storage."
  value       = module.bootstrap.bucket_name
}

output "state_bucket_id" {
  description = "ID of the S3 bucket used for Terraform remote state storage."
  value       = module.bootstrap.bucket_id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking."
  value       = module.bootstrap.dynamodb_name
}
