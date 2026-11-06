variable "aws_profile" {
  type        = string
  description = "Named AWS profile to use. Leave null to use the standard credential lookup (AWS_PROFILE, environment variables, default profile)."
  default     = null
}

provider "aws" {
  region  = "us-west-1"
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

output "account_id" {
  description = "The AWS account Terraform is talking to."
  value       = data.aws_caller_identity.current.account_id
}
