provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Exercise  = "06-state-drift"
    }
  }
}

# A standard-tier parameter has no storage charge. Do not change the tier:
# advanced parameters are billed.
resource "aws_ssm_parameter" "greeting" {
  name  = "/infra-experiments/exercise-06/greeting"
  type  = "String"
  tier  = "Standard"
  value = "hello"

  tags = {
    Purpose = "drift-exercise"
  }
}
