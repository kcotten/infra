# dev-network

The network for the `dev` environment: one VPC from [`modules/vpc-community`](../../modules/vpc-community/README.md), ready for EC2 instances or EKS clusters. It has its own state (`environments/dev-network/terraform.tfstate`), separate from `dev`, so the network can be planned and destroyed on its own.

To use the hand-written module instead, change the `source` in `main.tf` to `../../modules/vpc`. Both modules take the same inputs and return the same outputs.

## Cost

With the defaults (no NAT gateway) this costs very little: the VPC, subnets, route tables and S3 endpoint are free, and flow logs add a few pence of CloudWatch storage. **A NAT gateway costs roughly US$32 per month**, over this repository's US$5 limit. Only set `enable_nat_gateway = true` for a short session, then destroy.

## Usage

```bash
cp backend.hcl.example backend.hcl   # git-ignored; fill in the bucket from: terraform -chdir=../../bootstrap output backend_config_example
terraform init -backend-config=backend.hcl

# From the repository root, once initialised:
make plan DIR=environments/dev-network
make apply DIR=environments/dev-network    # manual, after reading the plan
make destroy DIR=environments/dev-network
```

For an EKS lab, create a git-ignored `terraform.tfvars` containing `eks_cluster_names = ["lab"]` and `enable_nat_gateway = true` (`make plan` does not forward `-var` flags). Other configurations can read the subnet IDs with a `terraform_remote_state` data source pointing at this state key.

## Not covered yet

- Planning or applying against a real account: this configuration is validated only.
- Compute (EC2, EKS) on top of the network.
