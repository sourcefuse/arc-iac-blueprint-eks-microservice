locals {
  name_prefix = "${var.namespace}-${var.environment}"

  # The private S3 bucket created by 11-s3 (holds the SPA; CloudFront origin via OAC).
  frontend_bucket = "${local.name_prefix}-frontend"

  cloudfront_config = {
    # Static frontend origin: the 11-s3 bucket (already exists — create_bucket=false).
    origins = [{
      origin_type   = "s3",
      origin_id     = local.frontend_bucket,
      domain_name   = "",
      bucket_name   = local.frontend_bucket,
      create_bucket = false
    }]

    namespace              = var.environment
    description            = "Frontend CDN for ${local.name_prefix} (EKS microservices blueprint)"
    default_root_object    = "index.html"
    route53_root_domain    = var.root_domain
    create_route53_records = var.root_domain != "" && var.ui_host != ""
    aliases                = var.ui_host != "" ? [var.ui_host] : []

    enable_logging = var.enable_access_logging

    default_cache_behavior = {
      origin_id                               = local.frontend_bucket
      allowed_methods                         = ["GET", "HEAD"]
      cached_methods                          = ["GET", "HEAD"]
      compress                                = true
      viewer_protocol_policy                  = "redirect-to-https"
      use_aws_managed_cache_policy            = true
      cache_policy_name                       = "CachingOptimized"
      use_aws_managed_origin_request_policy   = true
      origin_request_policy_name              = "CORS-S3Origin"
      use_aws_managed_response_headers_policy = true
      response_headers_policy_name            = "CORS-and-SecurityHeadersPolicy"
    }

    viewer_certificate = {
      cloudfront_default_certificate = false
      minimum_protocol_version       = "TLSv1.2_2021"
      ssl_support_method             = "sni-only"
    }

    acm_details = {
      domain_name               = var.ui_host
      subject_alternative_names = [var.ui_host]
    }

    # SPA client-side routing: return index.html (200) for 403/404 from S3.
    custom_error_responses = [
      {
        error_caching_min_ttl = 300
        error_code            = "403"
        response_code         = "200"
        response_page_path    = "/index.html"
      },
      {
        error_caching_min_ttl = 10
        error_code            = "404"
        response_code         = "200"
        response_page_path    = "/index.html"
      }
    ]

    price_class = var.price_class
  }
}
