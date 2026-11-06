# vpc

A repeatable AWS VPC for running either EKS clusters or plain EC2 instances. It owns the network only: no compute, no application security groups, no provider configuration (the calling configuration supplies the `aws` provider).

## Layout

| Tier | Size | Where | Notes |
| ---- | ---- | ----- | ----- |
| Public | /24 per AZ | `x.x.240.0` upwards | Route to the internet gateway. No automatic public IPs. |
| Private | /20 per AZ | `x.x.0.0` upwards | Larger because EKS pods use VPC addresses. Run nodes and instances here. |

- Subnets are spread across `az_count` Availability Zones (2 to 6).
- Each private subnet has its own route table, so NAT can be per-AZ.
- The default security group is stripped of all rules.
- A free S3 gateway endpoint is attached to the private route tables.
- Flow logs go to CloudWatch Logs with limited retention.

## Cost

NAT gateways are **off by default** because each costs roughly US$32 per month, well over this repository's US$5 budget. Without NAT, private subnets reach only S3 (via the endpoint). Turn NAT on for short sessions and destroy afterwards:

- `enable_nat_gateway = true` with `single_nat_gateway = true`: one gateway, not highly available.
- `enable_nat_gateway = true` with `single_nat_gateway = false`: one gateway per AZ.

EKS nodes need outbound access to pull images and reach the cluster API, so an EKS lab needs NAT (or VPC endpoints) enabled.

## Usage

Plain EC2:

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../modules/vpc"

  name = "ec2-lab"
  tags = { Owner = "kris" }
}

# Place instances in module.vpc.private_subnet_ids
```

EKS:

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "eks-lab"
  eks_cluster_names  = ["lab"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = { Owner = "kris" }
}

# Pass module.vpc.private_subnet_ids as the cluster's subnet_ids.
```

`eks_cluster_names` adds `kubernetes.io/cluster/<name> = shared` to all subnets, plus `kubernetes.io/role/elb` on public and `kubernetes.io/role/internal-elb` on private subnets, which the AWS load balancer controller uses for discovery.

## Tests

The tests mock the AWS provider, so they need no credentials and create nothing.

```bash
terraform -chdir=modules/vpc init
terraform -chdir=modules/vpc test
```

## Not covered yet

- IPv6 and dual-stack.
- Dedicated database or intra-VPC subnets.
- KMS encryption of the flow log group.
- Interface VPC endpoints (ECR, STS and so on), which can replace NAT for EKS at a different cost.
- Applying this module to a real account: it is validated and unit-tested only.
