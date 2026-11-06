# The same interface as modules/vpc, implemented with the community module
# (https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws).
# Comparing the two shows what the community module does for you and what it
# still leaves to the caller. Subnet layout matches modules/vpc:
#   - public /24s from x.x.240.0 upwards, private /20s from x.x.0.0 upwards.

data "aws_availability_zones" "available" {
  #checkov:skip=CKV_AWS_394: Taking the first N zones is intended; callers choose the count with az_count
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  public_subnet_cidrs  = [for index, az in local.azs : cidrsubnet(var.vpc_cidr, 8, 240 + index)]
  private_subnet_cidrs = [for index, az in local.azs : cidrsubnet(var.vpc_cidr, 4, index)]

  eks_cluster_tags = { for cluster in var.eks_cluster_names : "kubernetes.io/cluster/${cluster}" => "shared" }
  use_eks_tags     = length(var.eks_cluster_names) > 0

  public_subnet_tags = merge(
    local.eks_cluster_tags,
    local.use_eks_tags ? { "kubernetes.io/role/elb" = "1" } : {},
    { Tier = "public" },
  )
  private_subnet_tags = merge(
    local.eks_cluster_tags,
    local.use_eks_tags ? { "kubernetes.io/role/internal-elb" = "1" } : {},
    { Tier = "private" },
  )
}

module "vpc" {
  #checkov:skip=CKV_TF_1: Registry modules cannot use commit hashes; the exact version is pinned instead
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = var.name
  cidr = var.vpc_cidr
  azs  = local.azs

  public_subnets  = local.public_subnet_cidrs
  private_subnets = local.private_subnet_cidrs

  public_subnet_tags  = local.public_subnet_tags
  private_subnet_tags = local.private_subnet_tags

  # With NAT off, the community module makes one private route table per
  # subnet, so neither NAT option is set unless NAT is wanted.
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.enable_nat_gateway && var.single_nat_gateway
  one_nat_gateway_per_az = var.enable_nat_gateway && !var.single_nat_gateway

  # The community module already sets these, but they are stated here because
  # EKS depends on them and modules/vpc states them too.
  enable_dns_support            = true
  enable_dns_hostnames          = true
  map_public_ip_on_launch       = false
  manage_default_security_group = true

  enable_flow_log                                 = var.enable_flow_logs
  create_flow_log_cloudwatch_log_group            = var.enable_flow_logs
  create_flow_log_cloudwatch_iam_role             = var.enable_flow_logs
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_log_retention_days

  tags = var.tags
}

# The community module keeps endpoints in a separate submodule.
module "endpoints" {
  #checkov:skip=CKV_TF_1: Registry modules cannot use commit hashes; the exact version is pinned instead
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "6.7.3"

  count = var.enable_s3_gateway_endpoint ? 1 : 0

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "${var.name}-s3" }
    }
  }

  tags = var.tags
}
