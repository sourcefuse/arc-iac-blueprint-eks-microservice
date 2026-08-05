variable "namespace" {
  description = "Namespace prefix for all resource names (e.g. 'eb')."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. 'dev', 'staging', 'prod')."
  type        = string
}

variable "region" {
  description = "AWS region for CloudFront-adjacent resources (ACM certificates and the CLOUDFRONT-scope WAF are always in us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "compliance_profile" {
  description = "Compliance profile: 'general', 'hipaa', or 'pci_dss'."
  type        = string
  default     = "general"
}

# Domain wiring. Passed by the pipeline from HOSTED_ZONE / APP_SUBDOMAIN so the
# distribution alias + ACM cert (us-east-1) + Route53 record match the frontend URL.
variable "root_domain" {
  description = "Route53 hosted zone the frontend lives under (e.g. 'arc-poc.link')."
  type        = string
  default     = ""
}

variable "ui_host" {
  description = "Public hostname served by CloudFront for the UI (e.g. 'eksbp.arc-poc.link')."
  type        = string
  default     = ""
}

variable "enable_access_logging" {
  description = "Enable CloudFront access logging to the frontend S3 bucket."
  type        = bool
  default     = false
}

variable "price_class" {
  description = "CloudFront price class controlling which edge locations serve content."
  type        = string
  default     = "PriceClass_100"
}
