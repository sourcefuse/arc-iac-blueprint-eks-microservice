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

variable "github_token" {
  description = "GitHub PAT to register the runner (repo scope for repos_or_orgs='repos'). Passed as TF_VAR_github_token."
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub owner as 'owner/repo' (repos_or_orgs='repos'). Supplied by CI from github.repository (TF_VAR_github_owner); export it for local runs."
  type        = string
}

variable "repos_or_orgs" {
  description = "Register the runner at 'repos' or 'orgs' level."
  type        = string
  default     = "repos"
}

variable "runner_labels" {
  description = "Extra runner labels (comma-separated); cluster-touching jobs target these."
  type        = string
  default     = "eb"
}

variable "instance_type" {
  description = "EC2 instance type for the runner."
  type        = string
  default     = "t3a.medium"
}
