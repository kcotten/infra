variable "experiment_name" {
  type        = string
  description = "Name of this experiment, used in tags and file names."
  default     = "03-state-locking"

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

variable "hold_seconds" {
  type        = number
  description = "How long the apply holds the state lock, so a second run can try to take it."
  default     = 45

  validation {
    condition     = var.hold_seconds >= 1 && var.hold_seconds <= 300
    error_message = "hold_seconds must be between 1 and 300."
  }
}
