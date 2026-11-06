# vpc

A repeatable AWS VPC for running either EKS clusters or plain EC2 instances. It owns the network only: no compute, no application security groups, no provider configuration (the calling configuration supplies the `aws` provider).

## Layout

| Tier | Size | Where | Notes |
| ---- | ---- | ----- | ----- |
| Public | /24 per AZ | `x.x.240.0` upwards | Route to the internet gateway. No automatic public IPs. |
| Private | /20 per AZ | `x.x.0.0` upwards | Larger because EKS pods use VPC addresses. Run nodes and instances here. |

- Subnets are spread across `az_count` Availability Zones (2 to 6).
- Each private subnet has its own route table, so NAT can be per-AZ.
- The default security group is stripped of all rules.
- A free S3 gateway endpoint is attached to the private route tables.
- Flow logs go to CloudWatch Logs with limited retention.

## Cost

NAT gateways are **off by default** because each costs roughly US$32 per month, well over this repository's US$5 budget. Without NAT, private subnets reach only S3 (via the endpoint). Turn NAT on for short sessions and destroy afterwards:

- `enable_nat_gateway = true` with `single_nat_gateway = true`: one gateway, not highly available.
- `enable_nat_gateway = true` with `single_nat_gateway = false`: one gateway per AZ.

EKS nodes need outbound access to pull images and reach the cluster API, so an EKS lab needs NAT (or VPC endpoints) enabled.

## Usage

Plain EC2:

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../modules/vpc"

  name = "ec2-lab"
  tags = { Owner = "kris" }
}

# Place instances in module.vpc.private_subnet_ids
```

EKS:

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "eks-lab"
  eks_cluster_names  = ["lab"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = { Owner = "kris" }
}

# Pass module.vpc.private_subnet_ids as the cluster's subnet_ids.
```

`eks_cluster_names` adds `kubernetes.io/cluster/<name> = shared` to all subnets, plus `kubernetes.io/role/elb` on public and `kubernetes.io/role/internal-elb` on private subnets, which the AWS load balancer controller uses for discovery.

## Tests

The tests mock the AWS provider, so they need no credentials and create nothing.

```bash
terraform -chdir=modules/vpc init
terraform -chdir=modules/vpc test
```

## Not covered yet

- IPv6 and dual-stack.
- Dedicated database or intra-VPC subnets.
- KMS encryption of the flow log group.
- Interface VPC endpoints (ECR, STS and so on), which can replace NAT for EKS at a different cost.
- Applying this module to a real account: it is validated and unit-tested only.

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

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.flow_logs_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.flow_logs_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

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
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | IDs of the private route tables, one per AZ, in AZ order. Attach further gateway endpoints to these. |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets, one per AZ, in AZ order. Use these for EKS nodes and EC2 instances. |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | ID of the shared public route table. |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets, one per AZ, in AZ order. |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | IPv4 CIDR block of the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC. |
<!-- END_TF_DOCS -->
