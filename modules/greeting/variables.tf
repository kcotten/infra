variable "name" {
  type        = string
  description = "Short name for the greeting, used in the file name."

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.name))
    error_message = "name must be lower-case letters, digits and hyphens, and start with a letter or digit."
  }
}

variable "message" {
  type        = string
  description = "Text of the greeting."
  default     = "Hello"

  validation {
    condition     = length(trimspace(var.message)) > 0
    error_message = "message must not be empty."
  }
}

variable "directory" {
  type        = string
  description = "Directory the greeting file is written to. It is created if it does not exist."
}

variable "tags" {
  type        = map(string)
  description = "Tags recorded in the file, mirroring how cloud resources are tagged."
  default     = {}
}
