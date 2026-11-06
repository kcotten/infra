terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 2.0"
    }
  }
}

resource "random_pet" "name" {
  length = 2
}

output "name" {
  description = "A random two-word name."
  value       = random_pet.name.id
}
