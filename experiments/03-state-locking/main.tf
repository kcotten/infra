locals {
  tags = {
    Owner       = var.owner
    Experiment  = var.experiment_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# A deliberately slow step. Terraform holds the state lock for the whole apply,
# so a second run started during this window must be refused.
resource "terraform_data" "slow_step" {
  provisioner "local-exec" {
    command = "sleep ${var.hold_seconds}"
  }
}
