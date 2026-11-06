provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = var.owner
      Experiment  = "bootstrap"
      Environment = "shared"
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  state_bucket_name = coalesce(
    var.state_bucket_name,
    "infra-experiments-tfstate-${data.aws_caller_identity.current.account_id}-${var.region}",
  )

  # Percentages of the monthly budget at which actual spend triggers an email.
  alert_thresholds = [50, 80, 100]

  noncurrent_state_retention_days  = 90
  incomplete_upload_retention_days = 7
}

# ---------------------------------------------------------------------------
# State bucket: encrypted, versioned, private. Locking uses S3 native lock
# files (use_lockfile in each backend), so no extra table is needed.
# ---------------------------------------------------------------------------

# Skipped checks are deliberate for a single-user learning project:
#   CKV_AWS_144  cross-region replication would double the storage for no benefit
#   CKV_AWS_145  a KMS key costs about US$1 a month, a fifth of the whole budget; SSE-S3 is free
#   CKV_AWS_18   access logging needs a second bucket to store the logs
#   CKV2_AWS_62  event notifications are not needed
resource "aws_s3_bucket" "state" {
  #checkov:skip=CKV_AWS_144: Replication is unnecessary for learning state
  #checkov:skip=CKV_AWS_145: SSE-S3 is free; a KMS key would consume the budget
  #checkov:skip=CKV_AWS_18: Access logging is unnecessary for a single-user bucket
  #checkov:skip=CKV2_AWS_62: Event notifications are not needed

  bucket = local.state_bucket_name

  # Losing this bucket loses every environment's state, so make deletion deliberate.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.state.arn, "${aws_s3_bucket.state.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.deny_insecure_transport.json

  # Applying the public access block first avoids conflicting concurrent updates.
  depends_on = [aws_s3_bucket_public_access_block.state]
}

# Old state versions are kept for recovery, but not forever, to keep storage near zero.
resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = local.noncurrent_state_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = local.incomplete_upload_retention_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.state]
}

# ---------------------------------------------------------------------------
# Budget alert. It measures the whole account, so anything else running in
# this AWS account counts towards the limit too.
# ---------------------------------------------------------------------------

resource "aws_budgets_budget" "monthly" {
  name         = "infra-experiments-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "notification" {
    for_each = local.alert_thresholds

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = [var.alert_email]
    }
  }

  # An early warning if the month is on course to exceed the limit.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}
