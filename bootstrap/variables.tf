variable "namespace" {
  description = "Namespace prefix for the state backend resources (e.g. 'eksblueprint-arc')."
  type        = string
  default     = "eksblueprint-arc"
}

variable "environment" {
  description = "Deployment environment name (e.g. 'dev', 'staging', 'prod')."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region where the state bucket and DynamoDB lock table are created."
  type        = string
  default     = "us-east-1"
}

variable "enable_bucket_force_destroy" {
  description = "Set true only when you intend to fully tear down the state bucket."
  type        = bool
  default     = false
}
