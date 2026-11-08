variable "name" {
  description = "Name to be used across resources."
  type        = string
  default     = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "tags" {
  type = map(string)
  default = {
    Name        = "dev instance",
    Environment = "dev",
    Team        = "devops"
  }
}

variable "subnet_id" {
  description = "Subnet to launch the instance in. When null, the first subnet of the default VPC is used."
  type        = string
  default     = null
}
