output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (e.g. 'xyz.cloudfront.net') — use as the CNAME target."
  value       = module.cloudfront.cloudfront_domain_name
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate provisioned in us-east-1 and attached to the CloudFront distribution."
  value       = module.cloudfront.acm_certificate_arn
}
