output "instance_id" {
  description = "ID of the EC2 instance."
  value       = module.ec2_instance.id
}

output "public_ip" {
  description = "Public IP address of the instance, if it has one."
  value       = module.ec2_instance.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance."
  value       = module.ec2_instance.private_ip
}

output "subnet_id" {
  description = "Subnet the instance was launched in, whether provided or looked up."
  value       = local.subnet_id
}

output "availability_zone" {
  description = "Availability zone the instance is running in."
  value       = module.ec2_instance.availability_zone
}
