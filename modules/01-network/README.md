<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_network"></a> [network](#module\_network) | sourcefuse/arc-network/aws | 3.0.14 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.8 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones the VPC subnets are spread across. | `list(string)` | <pre>[<br/>  "us-east-1a",<br/>  "us-east-1b"<br/>]</pre> | no |
| <a name="input_compliance_profile"></a> [compliance\_profile](#input\_compliance\_profile) | Compliance profile: 'general', 'hipaa', or 'pci\_dss'. | `string` | `"general"` | no |
| <a name="input_enable_vpc_endpoints"></a> [enable\_vpc\_endpoints](#input\_enable\_vpc\_endpoints) | When true, adds S3 and DynamoDB gateway VPC endpoints so traffic to those services stays on the AWS backbone. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment name (e.g. 'dev', 'staging', 'prod'). | `string` | n/a | yes |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | Tenancy of instances launched into the VPC ('default' or 'dedicated'). | `string` | `"default"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace prefix for all resource names (e.g. 'eksblueprint'). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | `"us-east-1"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the platform VPC. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_endpoint_data"></a> [vpc\_endpoint\_data](#input\_vpc\_endpoint\_data) | Additional VPC endpoints to create (merged with the gateway endpoints added when enable\_vpc\_endpoints is true). | `any` | `[]` | no |
| <a name="input_vpc_flow_log_config"></a> [vpc\_flow\_log\_config](#input\_vpc\_flow\_log\_config) | VPC flow log configuration. If s3\_bucket\_arn is null only CloudWatch logging is enabled. | <pre>object({<br/>    enable            = optional(bool, true)<br/>    retention_in_days = optional(number, 7)<br/>    s3_bucket_arn     = optional(string, null)<br/>    traffic_type      = optional(string, "ALL")<br/>  })</pre> | <pre>{<br/>  "enable": true,<br/>  "retention_in_days": 7,<br/>  "s3_bucket_arn": null,<br/>  "traffic_type": "ALL"<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets. |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets. |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR block of the platform VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the platform VPC. |
<!-- END_TF_DOCS -->