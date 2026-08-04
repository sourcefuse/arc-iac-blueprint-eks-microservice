variable "namespace" {
  description = "Namespace prefix for all resource names (e.g. 'eb')."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. 'dev', 'staging', 'prod')."
  type        = string
}

variable "region" {
  description = "AWS region where the S3 bucket is created."
  type        = string
  default     = "us-east-1"
}

variable "compliance_profile" {
  description = "Compliance profile governing security controls; supported values: 'general', 'hipaa', 'pci_dss'."
  type        = string
  default     = "general"
}

variable "object_lock_enabled" {
  description = "Enable S3 Object Lock (WORM). Required for hipaa/pci profiles to satisfy immutability controls."
  type        = bool
  default     = false
}

variable "object_lock_config" {
  description = "Object Lock retention configuration. mode = COMPLIANCE or GOVERNANCE; days = retention window."
  type = object({
    mode = string
    days = number
  })
  default = {
    mode = "COMPLIANCE"
    days = 30
  }
}

variable "server_side_encryption_config_data" {
  description = "SSE configuration. Use sse_algorithm = 'aws:kms' with a kms_master_key_id for hipaa/pci."
  type = object({
    bucket_key_enabled = bool
    sse_algorithm      = string
    kms_master_key_id  = optional(string)
  })
  default = {
    bucket_key_enabled = true
    sse_algorithm      = "AES256"
    kms_master_key_id  = null
  }
}

variable "bucket_logging_data" {
  description = "Access logging configuration. Set enable = true for hipaa/pci audit trail."
  type = object({
    enable        = bool
    target_bucket = optional(string)
    target_prefix = optional(string)
  })
  default = {
    enable        = false
    target_bucket = null
    target_prefix = null
  }
}

variable "lifecycle_config" {
  description = "S3 lifecycle rules for data retention and storage-class transitions."
  type = object({
    enabled = bool
    rules   = list(any)
  })
  default = {
    enabled = false
    rules   = []
  }
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning."
  type        = bool
  default     = false
}