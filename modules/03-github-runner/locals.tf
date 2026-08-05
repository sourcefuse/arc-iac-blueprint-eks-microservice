locals {
  name_prefix = "${var.namespace}-${var.environment}"
  tags        = module.tags.tags
}
