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

variable "client_cidr_block" {
  description = <<-EOT
    IPv4 CIDR pool that connected VPN clients draw their addresses from. Must be
    /22 - /12 and MUST NOT overlap the VPC or its subnet CIDRs (AWS rejects the
    subnet association otherwise). Defaults to a dedicated 172.16.0.0/22 range,
    separate from the 10.0.0.0/8 VPCs. In real production, use a reserved
    non-overlapping VPN range from your IPAM/CIDR plan.
  EOT
  type        = string
  default     = "172.16.0.0/22"
}
