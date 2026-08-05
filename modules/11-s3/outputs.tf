output "bucket_id" {
  description = "Frontend S3 bucket name — the CloudFront S3 origin (see 12-cloudfront) and the deploy-frontend sync target."
  value       = module.s3.bucket_id
}

output "bucket_arn" {
  description = "ARN of the frontend S3 bucket."
  value       = module.s3.bucket_arn
}
