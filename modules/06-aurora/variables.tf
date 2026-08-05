variable "namespace" {
  description = "Namespace prefix for all resource names (e.g. 'eb')."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. 'dev', 'staging', 'prod')."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "compliance_profile" {
  description = "Compliance profile: 'general', 'hipaa', or 'pci_dss'."
  type        = string
  default     = "general"

  validation {
    condition     = contains(["general", "hipaa", "pci_dss"], var.compliance_profile)
    error_message = "compliance_profile must be one of: general, hipaa, pci_dss."
  }
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version."
  type        = string
  default     = "15.15"
}

variable "instance_class" {
  description = "Instance class for the Aurora writer instance."
  type        = string
  default     = "db.r6g.large"
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period (days) before the Aurora KMS key is deleted. Strict profiles require 30."
  type        = number
  default     = 7
}

variable "backup_retention" {
  description = "Number of days to retain automated backups (PITR window). Strict profiles require 35."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Prevent the Aurora cluster from being deleted. Strict profiles require true."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on cluster deletion. Strict profiles require false."
  type        = bool
  default     = true
}
