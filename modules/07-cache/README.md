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
| <a name="module_cache"></a> [cache](#module\_cache) | sourcefuse/arc-cache/aws | 0.0.7 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.8 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_automatic_failover_enabled"></a> [automatic\_failover\_enabled](#input\_automatic\_failover\_enabled) | Enable automatic failover to a replica if the primary node fails. | `bool` | `true` | no |
| <a name="input_compliance_profile"></a> [compliance\_profile](#input\_compliance\_profile) | Compliance profile: 'general', 'hipaa', or 'pci\_dss'. | `string` | `"general"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Redis engine version. | `string` | `"7.0"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment name (e.g. 'dev', 'staging', 'prod'). | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace prefix for all resource names (e.g. 'eksblueprint'). | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | ElastiCache Redis node type. | `string` | `"cache.t3.medium"` | no |
| <a name="input_num_cache_clusters"></a> [num\_cache\_clusters](#input\_num\_cache\_clusters) | Number of cache clusters (nodes) in the replication group. | `number` | `2` | no |
| <a name="input_port"></a> [port](#input\_port) | Port on which the Redis nodes accept connections. | `number` | `6379` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_address"></a> [cluster\_address](#output\_cluster\_address) | ElastiCache Redis primary endpoint address. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ElastiCache Redis replication group ID. |
| <a name="output_reader_endpoint_address"></a> [reader\_endpoint\_address](#output\_reader\_endpoint\_address) | ElastiCache Redis reader endpoint address. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID created for the Redis cluster. |
<!-- END_TF_DOCS -->