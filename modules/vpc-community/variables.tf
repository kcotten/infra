variable "name" {
  type        = string
  description = "Name prefix applied to every resource, for example 'dev' or 'eks-lab'."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.name))
    error_message = "name must be 2-31 characters: lower-case letters, digits and hyphens, starting with a letter."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR block for the VPC. Must be a /16 so the subnet layout (/20 private, /24 public) fits."
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && try(tonumber(split("/", var.vpc_cidr)[1]) == 16, false)
    error_message = "vpc_cidr must be a valid IPv4 CIDR with a /16 prefix, for example 10.0.0.0/16."
  }
}

variable "az_count" {
  type        = number
  description = "Number of Availability Zones to spread subnets across. EKS needs at least two."
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 6 && floor(var.az_count) == var.az_count
    error_message = "az_count must be a whole number between 2 and 6."
  }
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Give private subnets outbound internet access through NAT gateways. Costs roughly US$32 per month per gateway, so it is off by default."
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "Share one NAT gateway across all AZs (cheap, not highly available) instead of one per AZ. Only used when enable_nat_gateway is true."
  default     = true
}

variable "enable_s3_gateway_endpoint" {
  type        = bool
  description = "Add a free S3 gateway endpoint to the private route tables so S3 traffic bypasses NAT."
  default     = true
}

variable "enable_flow_logs" {
  type        = bool
  description = "Record VPC flow logs to CloudWatch Logs."
  default     = true
}

variable "flow_log_retention_days" {
  type        = number
  description = "Days to keep flow logs in CloudWatch. Must be a retention value CloudWatch Logs supports."
  default     = 14

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.flow_log_retention_days)
    error_message = "flow_log_retention_days must be a retention period CloudWatch Logs supports, such as 7, 14, 30 or 90."
  }
}

variable "eks_cluster_names" {
  type        = list(string)
  description = "Names of EKS clusters that will use this VPC. Adds the subnet tags that EKS and the AWS load balancer controller use for discovery. Leave empty for plain EC2 use."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource, merged with the module's own Name tags."
  default     = {}
}
