# Runs without AWS credentials: the AWS provider is mocked.
# Run with: terraform -chdir=bootstrap test

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }
}

variables {
  alert_email = "test@example.com"
}

run "state_bucket_is_named_after_account_and_region" {
  command = plan

  assert {
    condition     = aws_s3_bucket.state.bucket == "infra-experiments-tfstate-123456789012-us-west-1"
    error_message = "Bucket name should contain the account ID and region so it is globally unique."
  }
}

run "state_bucket_is_versioned_encrypted_and_private" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.state.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning must be enabled so earlier state can be restored."
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.state.rule).apply_server_side_encryption_by_default).sse_algorithm == "AES256"
    error_message = "State must be encrypted at rest."
  }

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.state.block_public_acls,
      aws_s3_bucket_public_access_block.state.block_public_policy,
      aws_s3_bucket_public_access_block.state.ignore_public_acls,
      aws_s3_bucket_public_access_block.state.restrict_public_buckets,
    ])
    error_message = "All four public access blocks must be on."
  }
}

run "budget_defaults_to_five_dollars_with_four_alerts" {
  command = plan

  assert {
    condition     = aws_budgets_budget.monthly.limit_amount == "5"
    error_message = "Default monthly budget should be US$5 (NFR-004)."
  }

  assert {
    condition     = length(aws_budgets_budget.monthly.notification) == 4
    error_message = "Expect alerts at 50%, 80% and 100% of actual spend, plus a 100% forecast."
  }
}

run "rejects_an_invalid_alert_email" {
  command = plan

  variables {
    alert_email = "not-an-email"
  }

  expect_failures = [var.alert_email]
}

run "rejects_a_zero_budget" {
  command = plan

  variables {
    monthly_budget_usd = 0
  }

  expect_failures = [var.monthly_budget_usd]
}
