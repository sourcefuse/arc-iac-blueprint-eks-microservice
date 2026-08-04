locals {
  name_prefix = "${var.namespace}-${var.environment}"
  tags        = module.tags.tags

  # Default action for the Web ACL: allow requests that match none of the rules.
  web_acl_default_action = {
    allow = {}
  }
}
