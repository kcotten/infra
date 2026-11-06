locals {
  tags = {
    Owner       = var.owner
    Experiment  = var.experiment_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  greetings = {
    kris  = "Hello"
    world = "Welcome"
  }
}

module "greeting" {
  source   = "../../modules/greeting"
  for_each = local.greetings

  name      = each.key
  message   = each.value
  directory = "${path.module}/output"
  tags      = local.tags
}
