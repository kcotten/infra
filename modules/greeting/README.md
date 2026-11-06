# greeting

A small starter module that writes a greeting file with a random, memorable suffix. It uses only the `local` and `random` providers, so it costs nothing and is safe to apply, change and destroy repeatedly.

It demonstrates the conventions every module in this repository follows: typed and described variables, input validation, outputs, pinned provider constraints and `terraform test` coverage.

## Usage
```hcl
module "welcome" {
  source = "../../modules/greeting"

  name      = "kris"
  message   = "Welcome"
  directory = "${path.module}/output"
  tags      = { Owner = "kris" }
}
```

## Tests
```bash
terraform -chdir=modules/greeting init
terraform -chdir=modules/greeting test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_local"></a> [local](#provider\_local) | 2.9.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [local_file.greeting](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_pet.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_directory"></a> [directory](#input\_directory) | Directory the greeting file is written to. It is created if it does not exist. | `string` | n/a | yes |
| <a name="input_message"></a> [message](#input\_message) | Text of the greeting. | `string` | `"Hello"` | no |
| <a name="input_name"></a> [name](#input\_name) | Short name for the greeting, used in the file name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags recorded in the file, mirroring how cloud resources are tagged. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_file_path"></a> [file\_path](#output\_file\_path) | Path of the greeting file that was written. |
| <a name="output_suffix"></a> [suffix](#output\_suffix) | Random suffix that makes the file name unique. |
<!-- END_TF_DOCS -->
