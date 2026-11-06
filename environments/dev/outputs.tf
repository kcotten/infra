output "account_id" {
  description = "AWS account this environment is applied to."
  value       = data.aws_caller_identity.current.account_id
}

output "welcome_file" {
  description = "Path of the greeting file written by the welcome module."
  value       = module.welcome.file_path
}
