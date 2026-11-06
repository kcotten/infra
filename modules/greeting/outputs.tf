output "file_path" {
  description = "Path of the greeting file that was written."
  value       = local_file.greeting.filename
}

output "suffix" {
  description = "Random suffix that makes the file name unique."
  value       = random_pet.suffix.id
}
