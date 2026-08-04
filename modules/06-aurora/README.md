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
| <a name="module_aurora"></a> [aurora](#module\_aurora) | sourcefuse/arc-db/aws | 4.0.4 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.8 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_backup_retention"></a> [backup\_retention](#input\_backup\_retention) | Number of days to retain automated backups (PITR window). Strict profiles require 35. | `number` | `7` | no |
| <a name="input_compliance_profile"></a> [compliance\_profile](#input\_compliance\_profile) | Compliance profile: 'general', 'hipaa', or 'pci\_dss'. | `string` | `"general"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Prevent the Aurora cluster from being deleted. Strict profiles require true. | `bool` | `false` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Aurora PostgreSQL engine version. | `string` | `"15.4"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment name (e.g. 'dev', 'staging', 'prod'). | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance class for the Aurora writer instance. | `string` | `"db.r6g.large"` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | Waiting period (days) before the Aurora KMS key is deleted. Strict profiles require 30. | `number` | `7` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace prefix for all resource names (e.g. 'eksblueprint'). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | `"us-east-1"` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Skip the final snapshot on cluster deletion. Strict profiles require false. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the Aurora cluster. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Writer endpoint (DNS) of the Aurora cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Identifier of the Aurora cluster. |
| <a name="output_master_user_secret"></a> [master\_user\_secret](#output\_master\_user\_secret) | Secrets Manager secret holding the managed master credentials. |
| <a name="output_port"></a> [port](#output\_port) | Port the Aurora cluster listens on. |
<!-- END_TF_DOCS -->