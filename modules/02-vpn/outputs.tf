output "client_vpn_arn" {
  description = "ARN of the Client VPN endpoint."
  value       = module.vpn.client_vpn_arn
}

output "client_vpn_id" {
  description = "Client VPN endpoint identifier as returned by arc-vpn (an ARN)."
  value       = module.vpn.client_vpn_id
}

output "client_vpn_endpoint_id" {
  description = "Bare Client VPN endpoint id (cvpn-endpoint-xxxx) for use with the AWS CLI / aws_ec2_client_vpn_* resources."
  value       = split("/", module.vpn.client_vpn_id)[1]
}

output "server_certificate_arn" {
  description = "ACM ARN of the server certificate presented by the endpoint."
  value       = module.vpn.server_certificate
}

output "ca_certificate_arn" {
  description = "ACM ARN of the self-signed CA certificate."
  value       = module.ca.certificate_arn
}

output "root_certificate_arn" {
  description = "ACM ARN of the client root certificate (endpoint root_certificate_chain_arn)."
  value       = module.root.certificate_arn
}
