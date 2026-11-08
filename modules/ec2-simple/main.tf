provider "aws" {
  region = var.region
}

locals {
  should_look_up_subnet = var.subnet_id == null
}

data "aws_vpc" "default" {
  count   = local.should_look_up_subnet ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = local.should_look_up_subnet ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

locals {
  # Sorted so the looked-up subnet is stable between runs.
  subnet_id = local.should_look_up_subnet ? sort(data.aws_subnets.default[0].ids)[0] : var.subnet_id
}

module "ec2_instance" {
  # Pinned to the commit for v6.4.1 (checkov CKV_TF_1). `version` is not valid with git sources.
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=294fb8928bc0f7e0d9ba5bea41a8236c9a7a95d9"

  name          = var.name
  instance_type = var.instance_type
  subnet_id     = local.subnet_id

  tags = var.tags
}
