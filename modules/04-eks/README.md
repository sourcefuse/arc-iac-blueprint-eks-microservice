# 04-eks — EKS cluster

The API server is **private-only** (`endpoint_public_access = false`), reachable
from inside the VPC — the in-VPC CI runner, or an operator laptop on the Client
VPN (`02-vpn`).

## Cluster access (who can `kubectl`)

The cluster runs in EKS **access-entry (`API`) mode**. Only IAM principals with an
access entry are authorized; everyone else gets a 401. Two knobs control this:

- **`ci_admin_role_arn`** — the CI/OIDC deploy role, granted cluster-admin so the
  pipeline can manage the cluster (passed by the workflow).
- **`admin_access_role_arns`** — additional operator/SSO role ARNs to grant
  cluster-admin **declaratively**, so engineers reaching the private API over the
  VPN are authorized without a manual `aws eks create-access-entry`. Defaults to
  `[]` (no extra admins). Set it per-environment in tfvars, e.g.:

  ```hcl
  admin_access_role_arns = [
    "arn:aws:iam::<account>:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_xxxx",
  ]
  ```

  For scoped access (dev teams limited to a namespace, read-only viewers), extend
  the access entries with `AmazonEKSEditPolicy` / `AmazonEKSViewPolicy` and a
  namespace `access_scope` — see `main.tf`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.55.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_eks"></a> [eks](#module\_eks) | sourcefuse/arc-eks/aws | 6.0.4 |
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
| <a name="input_compliance_profile"></a> [compliance\_profile](#input\_compliance\_profile) | Compliance profile: 'general', 'hipaa', or 'pci\_dss'. | `string` | `"general"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment name (e.g. 'dev', 'staging', 'prod'). | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | EKS Kubernetes version. | `string` | `"1.33"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace prefix for all resource names (e.g. 'eksblueprint'). | `string` | n/a | yes |
| <a name="input_node_desired_size"></a> [node\_desired\_size](#input\_node\_desired\_size) | Desired worker node count. | `number` | `3` | no |
| <a name="input_node_instance_types"></a> [node\_instance\_types](#input\_node\_instance\_types) | EC2 instance types for EKS worker nodes. | `list(string)` | <pre>[<br/>  "m5.xlarge"<br/>]</pre> | no |
| <a name="input_node_max_size"></a> [node\_max\_size](#input\_node\_max\_size) | Maximum worker node count. | `number` | `10` | no |
| <a name="input_node_min_size"></a> [node\_min\_size](#input\_node\_min\_size) | Minimum worker node count. | `number` | `2` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64-encoded certificate authority data for the EKS cluster. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS cluster API server endpoint. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | EKS cluster ID. |
| <a name="output_oidc_provider_url"></a> [oidc\_provider\_url](#output\_oidc\_provider\_url) | URL of the EKS OIDC provider for IRSA. |
<!-- END_TF_DOCS -->