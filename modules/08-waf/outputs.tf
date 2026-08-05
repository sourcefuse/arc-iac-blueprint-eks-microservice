output "arn" {
  description = "ARN of the CLOUDFRONT-scope WAF Web ACL. 12-cloudfront resolves it by name; exposed here for reference."
  value       = try(module.waf.arn[0], module.waf.arn)
}
