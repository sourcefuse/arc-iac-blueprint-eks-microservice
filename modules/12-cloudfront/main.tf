# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "12-cloudfront"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# CloudFront distribution that serves the static frontend (SPA) from the 11-s3
# bucket: CLOUDFRONT-scope WAF (08-waf), ACM cert (us-east-1), Route53 alias, and
# SPA error-page handling (403/404 -> index.html).
module "cloudfront" {
  source  = "sourcefuse/arc-cloudfront/aws"
  version = "4.1.3"

  origins                = local.cloudfront_config.origins
  namespace              = local.cloudfront_config.namespace
  description            = local.cloudfront_config.description
  default_root_object    = local.cloudfront_config.default_root_object
  route53_root_domain    = local.cloudfront_config.route53_root_domain
  create_route53_records = local.cloudfront_config.create_route53_records
  aliases                = local.cloudfront_config.aliases
  default_cache_behavior = local.cloudfront_config.default_cache_behavior
  viewer_certificate     = local.cloudfront_config.viewer_certificate
  acm_details            = local.cloudfront_config.acm_details
  custom_error_responses = local.cloudfront_config.custom_error_responses
  price_class            = local.cloudfront_config.price_class
  web_acl_id             = data.aws_wafv2_web_acl.this.arn

  providers = {
    aws.acm = aws.us_east_1
  }
}