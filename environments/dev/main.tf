provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = var.owner
      Experiment  = "environment"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  tags = {
    Owner       = var.owner
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# A free, local-only resource that proves the environment works end to end.
# Replace or extend with real resources as experiments graduate into environments.
module "welcome" {
  source = "../../modules/greeting"

  name      = var.environment
  message   = "Welcome ${var.owner}"
  directory = "${path.module}/output"
  tags      = local.tags
}
