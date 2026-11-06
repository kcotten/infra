#!/usr/bin/env bash
# Simulates someone changing the parameter by hand, outside Terraform.
# Run it only after `terraform apply` has created the parameter.
set -euo pipefail

aws ssm add-tags-to-resource \
  --region us-west-1 \
  --resource-type Parameter \
  --resource-id /infra-experiments/exercise-06/greeting \
  --tags Key=Purpose,Value=changed-by-hand

echo "Changed the Purpose tag by hand. Now run: terraform plan"
