variable "region" {
  type        = string
  description = "AWS region for this environment."
  default     = "us-west-1"
}

variable "environment" {
  type        = string
  description = "Name of this environment, recorded in the Environment tag."
  default     = "sandbox"
}

variable "owner" {
  type        = string
  description = "Who owns this environment, recorded in the Owner tag."
  default     = "kris"
}
