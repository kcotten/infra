# ec2 simple module
An example module that will create a basic ec2 instance for experimentation.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.72.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.72.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git | 294fb8928bc0f7e0d9ba5bea41a8236c9a7a95d9 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_subnets.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t3.micro"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used across resources. | `string` | `"dev"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet to launch the instance in. When null, the first subnet of the default VPC is used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "Name": "dev instance",<br/>  "Team": "devops"<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | Availability zone the instance is running in. |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the EC2 instance. |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP address of the instance. |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP address of the instance, if it has one. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Subnet the instance was launched in, whether provided or looked up. |
<!-- END_TF_DOCS -->
