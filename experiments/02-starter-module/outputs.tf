output "tags" {
  description = "Tags every resource in this experiment should carry."
  value       = local.tags
}

output "greeting_files" {
  description = "Greeting files written, keyed by greeting name."
  value       = { for name, greeting in module.greeting : name => greeting.file_path }
}
