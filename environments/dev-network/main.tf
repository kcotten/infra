provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = var.owner
      Experiment  = "environment"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

# Network for this environment. Compute (EC2, EKS) belongs in separate
# configurations that read these outputs, so the network can outlive them.
# Swap the source to ../../modules/vpc to use the hand-written module instead;
# both take the same inputs and return the same outputs.
module "vpc" {
  source = "../../modules/vpc-community"

  name               = var.environment
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  enable_nat_gateway = var.enable_nat_gateway
  eks_cluster_names  = var.eks_cluster_names
}
