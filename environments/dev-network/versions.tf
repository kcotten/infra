terraform {
  required_version = ">= 1.10"

  # Bucket, key and region come from backend.hcl: terraform init -backend-config=backend.hcl
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
