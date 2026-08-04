locals {
  name_prefix = "${var.namespace}-${var.environment}"
  tags        = module.tags.tags

  # VPC flow log configuration, passed straight through to the network module.
  vpc_flow_log_config = {
    enable            = var.vpc_flow_log_config.enable
    retention_in_days = var.vpc_flow_log_config.retention_in_days
    s3_bucket_arn     = var.vpc_flow_log_config.s3_bucket_arn
    traffic_type      = var.vpc_flow_log_config.traffic_type
  }

  # Gateway endpoints (S3 + DynamoDB) keep traffic to those services on the AWS
  # backbone instead of traversing the public internet / NAT. Only added when
  # enable_vpc_endpoints is true, then merged with any caller-supplied endpoints.
  gateway_vpc_endpoints = var.enable_vpc_endpoints ? [
    {
      service            = "s3"
      route_table_filter = "private"
    },
    {
      service            = "dynamodb"
      route_table_filter = "private"
    },
  ] : []

  vpc_endpoint_data = concat(local.gateway_vpc_endpoints, var.vpc_endpoint_data)
}
