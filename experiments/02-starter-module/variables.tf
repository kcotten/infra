variable "experiment_name" {
  type        = string
  description = "Name of this experiment, used in tags and file names."
  default     = "02-starter-module"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.experiment_name))
    error_message = "experiment_name must be lower-case letters, digits and hyphens, and start with a letter or digit."
  }
}

variable "owner" {
  type        = string
  description = "Who owns this experiment."
  default     = "kris"
}

variable "environment" {
  type        = string
  description = "Environment this experiment belongs to."
  default     = "sandbox"
}
