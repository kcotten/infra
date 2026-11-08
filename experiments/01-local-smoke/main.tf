locals {
  tags = {
    Owner       = var.owner
    Experiment  = var.experiment_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Replace this placeholder with the resources you want to experiment with.
resource "random_pet" "example" {
  length = 2
}

resource "local_file" "hello" {
  filename = "${path.module}/greeting.txt"
  content  = "Hello from ${var.experiment_name}: ${random_pet.example.id}\n"
}

# renamed 11/6/2026
moved {
  from = local_file.greeting
  to   = local_file.hello
}
