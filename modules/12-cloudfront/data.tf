# The CLOUDFRONT-scope Web ACL created by 08-waf (us-east-1). Attached to the
# distribution below via web_acl_id — this is the WAF that fronts the public UI.
data "aws_wafv2_web_acl" "this" {
  name     = "${var.namespace}-${var.environment}-waf"
  scope    = "CLOUDFRONT"
  provider = aws.us_east_1
}
