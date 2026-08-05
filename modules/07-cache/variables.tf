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

variable "node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.medium"
}

variable "engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.0"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (nodes) in the replication group."
  type        = number
  default     = 2
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover to a replica if the primary node fails."
  type        = bool
  default     = true
}

variable "port" {
  description = "Port on which the Redis nodes accept connections."
  type        = number
  default     = 6379
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period (days) before this layer's cache KMS key is deleted. Strict profiles require 30."
  type        = number
  default     = 7
}
