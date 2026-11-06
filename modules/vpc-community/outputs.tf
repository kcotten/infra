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
  value       = module.vpc.azs
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per AZ, in AZ order."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, one per AZ, in AZ order. Use these for EKS nodes and EC2 instances."
  value       = module.vpc.private_subnets
}

output "public_route_table_id" {
  description = "ID of the shared public route table."
  value       = one(module.vpc.public_route_table_ids)
}

output "private_route_table_ids" {
  description = "IDs of the private route tables. One per AZ, except with a single NAT gateway, when the community module shares one table between all private subnets."
  value       = module.vpc.private_route_table_ids
}

output "nat_public_ips" {
  description = "Public IP addresses of the NAT gateways, useful for allow-listing outbound traffic. Empty when NAT is disabled."
  value       = module.vpc.nat_public_ips
}

output "default_security_group_id" {
  description = "ID of the VPC's default security group, which has all rules removed."
  value       = module.vpc.default_security_group_id
}
