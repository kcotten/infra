variable "region" {
  type        = string
  description = "AWS region for this environment."
  default     = "us-west-1"
}

variable "environment" {
  type        = string
  description = "Name of this environment, recorded in the Environment tag and used to name the VPC."
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "Who owns this environment, recorded in the Owner tag."
  default     = "kris"
}

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR block for the VPC. Must be a /16."
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Number of Availability Zones to use. us-west-1 offers only two."
  default     = 2
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Give private subnets outbound internet access. A NAT gateway costs roughly US$32 per month, so leave this off unless a lab needs it, and destroy afterwards."
  default     = false
}

variable "eks_cluster_names" {
  type        = list(string)
  description = "Names of EKS clusters that will use this VPC. Adds the subnet tags EKS needs for load balancer discovery."
  default     = []
}
