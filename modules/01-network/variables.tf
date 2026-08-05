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

variable "vpc_cidr" {
  description = "CIDR block for the platform VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones the VPC subnets are spread across."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_flow_log_config" {
  description = "VPC flow log configuration. If s3_bucket_arn is null only CloudWatch logging is enabled."
  type = object({
    enable            = optional(bool, true)
    retention_in_days = optional(number, 7)
    s3_bucket_arn     = optional(string, null)
    traffic_type      = optional(string, "ALL")
  })
  default = {
    enable            = true
    retention_in_days = 7
    s3_bucket_arn     = null
    traffic_type      = "ALL"
  }
}

variable "vpc_endpoint_data" {
  description = "Additional VPC endpoints to create (merged with the gateway endpoints added when enable_vpc_endpoints is true)."
  type        = any
  default     = []
}

variable "instance_tenancy" {
  description = "Tenancy of instances launched into the VPC ('default' or 'dedicated')."
  type        = string
  default     = "default"
}

variable "nat_gateway_config" {
  description = <<-EOT
    NAT gateway topology.
      - mode = "regional": a single multi-AZ NAT gateway spanning all AZs. AWS
        keeps it available across AZs, so it is HA without running (and paying
        for) one gateway + EIP per AZ. This is the default.
      - mode = "zonal"   : one NAT gateway per AZ (traditional).
    When mode = "regional", regional_auto_mode = true lets AWS manage the AZs
    and EIPs; set it false and supply regional_az_eip_config to pin EIPs per AZ.
  EOT
  type = object({
    mode                   = optional(string, "regional")
    regional_auto_mode     = optional(bool, true)
    regional_az_eip_config = optional(map(list(string)), {})
  })
  default = {
    mode               = "regional"
    regional_auto_mode = true
  }

  validation {
    condition     = contains(["zonal", "regional"], var.nat_gateway_config.mode)
    error_message = "nat_gateway_config.mode must be either 'zonal' or 'regional'."
  }
}

variable "enable_vpc_endpoints" {
  description = "When true, adds S3 and DynamoDB gateway VPC endpoints so traffic to those services stays on the AWS backbone."
  type        = bool
  default     = false
}
