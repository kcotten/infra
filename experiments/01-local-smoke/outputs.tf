output "tags" {
  description = "Tags every resource in this experiment should carry."
  value       = local.tags
}

output "example_name" {
  description = "Randomly generated name used in the greeting."
  value       = random_pet.example.id
}

output "greeting_path" {
  description = "Where the greeting file was written."
  value       = local_file.hello.filename
}
