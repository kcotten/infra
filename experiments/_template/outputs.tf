output "tags" {
  description = "Tags every resource in this experiment should carry."
  value       = local.tags
}

output "example_name" {
  description = "Placeholder output; replace with real outputs."
  value       = random_pet.example.id
}
