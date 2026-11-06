variable "region" {
  type        = string
  description = "AWS region for the state bucket."
  default     = "us-west-1"
}

variable "alert_email" {
  type        = string
  description = "Email address that receives budget alerts. Set it in the git-ignored terraform.tfvars."

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must look like an email address, for example you@example.com."
  }
}

variable "monthly_budget_usd" {
  type        = number
  description = "Monthly spend limit in US dollars that the budget alerts are measured against."
  default     = 5

  validation {
    condition     = var.monthly_budget_usd > 0
    error_message = "monthly_budget_usd must be greater than zero."
  }
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the state bucket. Defaults to a name containing the account ID and region, because bucket names are global."
  default     = null
}

variable "owner" {
  type        = string
  description = "Who owns these resources, recorded in the Owner tag."
  default     = "kris"
}
