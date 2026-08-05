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

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten (MUTABLE or IMMUTABLE)."
  type        = string
  default     = "IMMUTABLE"
}

variable "encryption_type" {
  description = "ECR encryption type for the repository at rest (AES256 or KMS)."
  type        = string
  default     = "AES256"
}

variable "force_delete" {
  description = "Delete the repository even if it still contains images. Enabled so the destroy workflow can tear down the repo without manually emptying it first."
  type        = bool
  default     = true
}
