# vpc-community

The same VPC as [`modules/vpc`](../vpc/README.md), built on the community [`terraform-aws-modules/vpc/aws`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) module (pinned to 6.7.3). It has identical inputs and outputs, so the two are interchangeable and the differences between them are easy to see.

## Why have both

| | `modules/vpc` (hand-written) | `modules/vpc-community` (wrapper) |
| --- | --- | --- |
| Code you maintain | About 250 lines, 18 resource blocks | About 90 lines, two module calls, mostly mapping inputs |
| Understanding | Every resource and route is visible and explained | Behaviour lives in a large external module with hundreds of variables |
| Subnet CIDRs and AZs | Computed inside the module | The community module expects them as lists, so this wrapper computes them |
| Private route tables | Always one per AZ | One per NAT gateway, so a **single NAT shares one table** across all private subnets |
| Flow logs | Explicit log group, IAM role and policy | Three flags; the community module creates the same pieces |
| S3 gateway endpoint | One resource | Separate `vpc-endpoints` submodule, with a lookup of the service |
| Upgrades | You decide what changes | Version bumps may rename inputs or resources (6.x already differs from 5.x) |
| Extras you could enable | Only what you write | IPv6, database and intra subnets, VPN gateway, NACLs, secondary CIDRs and more |

Use the hand-written module to learn how the pieces fit. Use the community wrapper when you want the long tail of features without writing them, and accept the dependency.

## Differences in behaviour

- `private_route_table_ids` has one entry per AZ, except when `enable_nat_gateway` and `single_nat_gateway` are both true, when it has one shared entry.
- Resource names and tags follow the community module's conventions, so they are close to, but not identical to, `modules/vpc`.
- The wrapper pins an exact module version. Bump it deliberately and run the tests.

See [`modules/vpc`](../vpc/README.md) for the subnet layout, cost notes and usage examples; they apply here unchanged.

## Tests

The tests mirror `modules/vpc/tests` and mock the AWS provider, so they need no credentials and create nothing.

```bash
terraform -chdir=modules/vpc-community init
terraform -chdir=modules/vpc-community test
```

## Not covered yet

- Applying this module to a real account: it is validated and unit-tested only.
- Verifying that the two modules produce equivalent plans against real AWS. The tests check intent, not a resource-by-resource diff.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.72.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.72.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_endpoints"></a> [endpoints](#module\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 6.7.3 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 6.7.3 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Number of Availability Zones to spread subnets across. EKS needs at least two. | `number` | `2` | no |
| <a name="input_eks_cluster_names"></a> [eks\_cluster\_names](#input\_eks\_cluster\_names) | Names of EKS clusters that will use this VPC. Adds the subnet tags that EKS and the AWS load balancer controller use for discovery. Leave empty for plain EC2 use. | `list(string)` | `[]` | no |
| <a name="input_enable_flow_logs"></a> [enable\_flow\_logs](#input\_enable\_flow\_logs) | Record VPC flow logs to CloudWatch Logs. | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Give private subnets outbound internet access through NAT gateways. Costs roughly US$32 per month per gateway, so it is off by default. | `bool` | `false` | no |
| <a name="input_enable_s3_gateway_endpoint"></a> [enable\_s3\_gateway\_endpoint](#input\_enable\_s3\_gateway\_endpoint) | Add a free S3 gateway endpoint to the private route tables so S3 traffic bypasses NAT. | `bool` | `true` | no |
| <a name="input_flow_log_retention_days"></a> [flow\_log\_retention\_days](#input\_flow\_log\_retention\_days) | Days to keep flow logs in CloudWatch. Must be a retention value CloudWatch Logs supports. | `number` | `14` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix applied to every resource, for example 'dev' or 'eks-lab'. | `string` | n/a | yes |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Share one NAT gateway across all AZs (cheap, not highly available) instead of one per AZ. Only used when enable\_nat\_gateway is true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every resource, merged with the module's own Name tags. | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | IPv4 CIDR block for the VPC. Must be a /16 so the subnet layout (/20 private, /24 public) fits. | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | Availability Zones the subnets are spread across. |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | ID of the VPC's default security group, which has all rules removed. |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | Public IP addresses of the NAT gateways, useful for allow-listing outbound traffic. Empty when NAT is disabled. |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | IDs of the private route tables. One per AZ, except with a single NAT gateway, when the community module shares one table between all private subnets. |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets, one per AZ, in AZ order. Use these for EKS nodes and EC2 instances. |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | ID of the shared public route table. |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets, one per AZ, in AZ order. |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | IPv4 CIDR block of the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC. |
<!-- END_TF_DOCS -->
