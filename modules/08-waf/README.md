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
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.8 |
| <a name="module_waf"></a> [waf](#module\_waf) | sourcefuse/arc-waf/aws | 1.0.6 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_compliance_profile"></a> [compliance\_profile](#input\_compliance\_profile) | Compliance profile: 'general', 'hipaa', or 'pci\_dss'. | `string` | `"general"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment name (e.g. 'dev', 'staging', 'prod'). | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace prefix for all resource names (e.g. 'eksblueprint'). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | `"us-east-1"` | no |
| <a name="input_waf_rate_limit"></a> [waf\_rate\_limit](#input\_waf\_rate\_limit) | Maximum requests per 5-minute period allowed from a single IP before the RateLimit rule blocks it. | `number` | `5000` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the WAF Web ACL (REGIONAL), for association with the ALB. |
<!-- END_TF_DOCS -->