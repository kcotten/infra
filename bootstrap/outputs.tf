output "state_bucket_name" {
  description = "Name of the bucket that holds remote state."
  value       = aws_s3_bucket.state.id
}

output "region" {
  description = "Region the state bucket lives in."
  value       = var.region
}

output "backend_config_example" {
  description = "Contents for an environment's backend.hcl. Change the key for each environment or experiment."
  value       = <<-EOT
    bucket       = "${aws_s3_bucket.state.id}"
    key          = "environments/dev/terraform.tfstate"
    region       = "${var.region}"
    encrypt      = true
    use_lockfile = true
  EOT
}

output "budget_name" {
  description = "Name of the monthly budget."
  value       = aws_budgets_budget.monthly.name
}
