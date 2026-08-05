# 02-vpn — AWS Client VPN (mutual TLS)

Provisions an **AWS Client VPN endpoint** so engineers can reach VPC-private
resources from their laptops — most importantly the **private EKS API server**
(the cluster endpoint is private-only), plus Aurora, Redis and any internal ALBs.

> The ArgoCD / SigNoz / sample-app UIs are exposed via **public** internet-facing
> ALBs and do **not** need the VPN. This VPN is for operator/CLI access
> (`kubectl`, `helm`, `argocd`) to the **private** Kubernetes API and data stores.

It builds, via the `arc-vpn` module:

- a self-signed **CA** and **client root** certificate (`//modules/certificate`),
  imported to **ACM** and stored in **SSM** (never written to disk in CI);
- a **certificate-authenticated** (mutual TLS) Client VPN endpoint associated
  with the **private subnets**;
- a single **authorization rule** for the VPC CIDR (only one VPC/VPN here, so no
  extra target networks or routes).

This layer mirrors the shape of the existing prod `client-vpn` module.

> **No EKS security-group change is required.** AWS Client VPN source-NATs client
> traffic to the association-subnet ENI (inside the VPC CIDR), which the EKS
> cluster SG rule "443 from VPC CIDR" already permits.

## Dependencies

`01-network` (VPC + private subnets). Looked up by tag, so this layer stays
independently `terraform validate`-able.

## Connecting (operator quickstart)

1. Download the client VPN configuration:
   `aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id <id>`
   (`<id>` = `terraform output -raw client_vpn_endpoint_id`).
2. Retrieve the **client root** certificate + private key from SSM (parameters
   created by the `root` certificate module) and append `<cert>`/`<key>` blocks
   to the downloaded `.ovpn`.
3. Import the `.ovpn` into the AWS VPN Client (or any OpenVPN client) and connect.
4. Verify with `kubectl get ns` against the private EKS API.

## Client CIDR

`client_cidr_block` defaults to a dedicated **`172.16.0.0/22`** range and **must
not overlap the VPC or its subnet CIDRs** — AWS rejects the subnet association
otherwise (`InvalidClientVpnSubnetId.OverlappingCidr`). Deriving it from the VPC
CIDR (`cidrsubnet(...)`, the prod convention) lands *inside* this VPC's `/18`
subnets and fails, so a separate non-overlapping range is used. In real
production, use a reserved VPN range from your IPAM/CIDR plan.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 6.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_ca"></a> [ca](#module\_ca) | sourcefuse/arc-vpn/aws//modules/certificate | 3.0.1 |
| <a name="module_root"></a> [root](#module\_root) | sourcefuse/arc-vpn/aws//modules/certificate | 3.0.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.9 |
| <a name="module_vpn"></a> [vpn](#module\_vpn) | sourcefuse/arc-vpn/aws | 3.0.1 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace prefix for all resource names (e.g. 'eb'). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment name (e.g. 'dev', 'staging', 'prod'). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | `"us-east-1"` | no |
| <a name="input_compliance_profile"></a> [compliance\_profile](#input\_compliance\_profile) | Compliance profile: 'general', 'hipaa', or 'pci\_dss'. | `string` | `"general"` | no |
| <a name="input_client_cidr_block"></a> [client\_cidr\_block](#input\_client\_cidr\_block) | Client address pool; must not overlap the VPC/subnet CIDRs. | `string` | `"172.16.0.0/22"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_vpn_arn"></a> [client\_vpn\_arn](#output\_client\_vpn\_arn) | ARN of the Client VPN endpoint. |
| <a name="output_client_vpn_id"></a> [client\_vpn\_id](#output\_client\_vpn\_id) | Client VPN endpoint identifier as returned by arc-vpn (an ARN). |
| <a name="output_client_vpn_endpoint_id"></a> [client\_vpn\_endpoint\_id](#output\_client\_vpn\_endpoint\_id) | Bare Client VPN endpoint id (cvpn-endpoint-xxxx). |
| <a name="output_server_certificate_arn"></a> [server\_certificate\_arn](#output\_server\_certificate\_arn) | ACM ARN of the server certificate. |
| <a name="output_ca_certificate_arn"></a> [ca\_certificate\_arn](#output\_ca\_certificate\_arn) | ACM ARN of the self-signed CA certificate. |
| <a name="output_root_certificate_arn"></a> [root\_certificate\_arn](#output\_root\_certificate\_arn) | ACM ARN of the client root certificate. |
<!-- END_TF_DOCS -->
