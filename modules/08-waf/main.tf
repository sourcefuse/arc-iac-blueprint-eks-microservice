# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "08-waf"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# CLOUDFRONT-scope Web ACL that fronts the public frontend distribution
# (12-cloudfront attaches it via web_acl_id). CLOUDFRONT-scope Web ACLs MUST live
# in us-east-1 (see version.tf). The UI is served from CloudFront + S3, so WAF is
# applied at the edge here rather than on the ALB — mirroring the ECS blueprint.
module "waf" {
  source  = "sourcefuse/arc-waf/aws"
  version = "1.0.8"

  web_acl_name           = "${local.name_prefix}-waf"
  web_acl_default_action = keys(local.web_acl_default_action)[0]
  web_acl_scope          = "CLOUDFRONT"

  web_acl_visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  # arc-waf iterates web_acl_rules with keys() (it must be a map) and skips those
  # rules when web_acl_rule_json is set. Pass the rules as raw AWS WAFv2 JSON via
  # rule_json and keep web_acl_rules an empty map.
  web_acl_rules = {}
  web_acl_rule_json = jsonencode([
    {
      Name           = "AWSManagedRulesCommonRuleSet"
      Priority       = 0
      OverrideAction = { None = {} }
      Statement = {
        ManagedRuleGroupStatement = {
          VendorName = "AWS"
          Name       = "AWSManagedRulesCommonRuleSet"
        }
      }
      VisibilityConfig = {
        CloudWatchMetricsEnabled = true
        MetricName               = "${local.name_prefix}-common-rules"
        SampledRequestsEnabled   = true
      }
    },
    {
      Name     = "RateLimit"
      Priority = 1
      Action   = { Block = {} }
      Statement = {
        RateBasedStatement = {
          Limit            = var.waf_rate_limit
          AggregateKeyType = "IP"
        }
      }
      VisibilityConfig = {
        CloudWatchMetricsEnabled = true
        MetricName               = "${local.name_prefix}-rate-limit"
        SampledRequestsEnabled   = true
      }
    }
  ])

  tags = local.tags
}
