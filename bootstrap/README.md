<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | sourcefuse/arc-bootstrap/aws | 1.1.10 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_ssm_parameter.terraform_backend_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_bucket_force_destroy"></a> [enable\_bucket\_force\_destroy](#input\_enable\_bucket\_force\_destroy) | Set true only when you intend to fully tear down the state bucket. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment name (e.g. 'dev', 'staging', 'prod'). | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace prefix for the state backend resources (e.g. 'eksblueprint-arc'). | `string` | `"eksblueprint-arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where the state bucket and DynamoDB lock table are created. | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dynamodb_table_name"></a> [dynamodb\_table\_name](#output\_dynamodb\_table\_name) | Name of the DynamoDB table used for Terraform state locking. |
| <a name="output_state_bucket_id"></a> [state\_bucket\_id](#output\_state\_bucket\_id) | ID of the S3 bucket used for Terraform remote state storage. |
| <a name="output_state_bucket_name"></a> [state\_bucket\_name](#output\_state\_bucket\_name) | Name of the S3 bucket used for Terraform remote state storage. |
<!-- END_TF_DOCS -->