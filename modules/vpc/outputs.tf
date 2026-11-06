output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "Availability Zones the subnets are spread across."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per AZ, in AZ order."
  value       = [for az in local.azs : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, one per AZ, in AZ order. Use these for EKS nodes and EC2 instances."
  value       = [for az in local.azs : aws_subnet.private[az].id]
}

output "public_route_table_id" {
  description = "ID of the shared public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables, one per AZ, in AZ order. Attach further gateway endpoints to these."
  value       = [for az in local.azs : aws_route_table.private[az].id]
}

output "nat_public_ips" {
  description = "Public IP addresses of the NAT gateways, useful for allow-listing outbound traffic. Empty when NAT is disabled."
  value       = aws_eip.nat[*].public_ip
}

output "default_security_group_id" {
  description = "ID of the VPC's default security group, which has all rules removed."
  value       = aws_default_security_group.default.id
}
