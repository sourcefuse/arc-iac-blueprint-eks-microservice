output "vpc_id" {
  description = "ID of the platform VPC."
  value       = module.network.id
}

output "vpc_cidr" {
  description = "CIDR block of the platform VPC."
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.network.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "IDs of the per-AZ NAT gateways (populated when nat_gateway_config.mode = 'zonal')."
  value       = module.network.nat_gateway_ids
}

output "regional_nat_gateway_id" {
  description = "ID of the single regional NAT gateway (populated when nat_gateway_config.mode = 'regional')."
  value       = module.network.regional_nat_gateway_id
}
