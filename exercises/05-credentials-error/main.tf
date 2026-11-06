provider "aws" {
  region  = "us-west-1"
  profile = "infra-experiments-typo"
}

data "aws_caller_identity" "current" {}

output "account_id" {
  description = "The AWS account Terraform is talking to."
  value       = data.aws_caller_identity.current.account_id
}
