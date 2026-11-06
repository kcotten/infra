output "account_id" {
  description = "AWS account this environment is applied to."
  value       = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "availability_zones" {
  description = "Availability Zones the subnets are spread across."
  value       = module.vpc.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per AZ."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, one per AZ. Place EC2 instances and EKS nodes here."
  value       = module.vpc.private_subnet_ids
}

output "private_route_table_ids" {
  description = "IDs of the private route tables. Attach further gateway endpoints to these."
  value       = module.vpc.private_route_table_ids
}

output "nat_public_ips" {
  description = "Public IP addresses of the NAT gateways. Empty when NAT is disabled."
  value       = module.vpc.nat_public_ips
}
