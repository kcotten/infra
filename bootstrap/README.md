# Bootstrap

Creates the shared AWS resources everything else depends on:

| Resource | Purpose |
|----------|---------|
| S3 bucket `infra-experiments-tfstate-<account>-<region>` | Remote state for every environment and experiment. Versioned, encrypted (SSE-S3), private, TLS-only, old versions expire after 90 days. |
| Budget `infra-experiments-monthly` | US$5 a month, with emails at 50%, 80% and 100% of actual spend and when the forecast passes 100%. |

State locking needs no extra resource. Each environment sets `use_lockfile = true` in its backend and S3 holds the lock as a small object next to the state.

## Cost
Effectively nothing: state files are a few kilobytes, S3 lifecycle rules remove old versions, and AWS does not charge for budgets that only send notifications (charges apply to action-enabled budgets beyond the first two). See [docs/costs.md](../docs/costs.md). The budget measures the **whole account**, so anything else running there counts towards the US$5.

## Local state
The bootstrap creates the bucket, so it cannot store its own state in it. Its state stays **local** in `bootstrap/terraform.tfstate`, which is git-ignored. Back it up by hand after every apply:

```bash
cp bootstrap/terraform.tfstate ~/backups/infra-bootstrap-$(date +%F).tfstate
```

The state file can contain sensitive values, so keep the backup somewhere private. If it is lost, see [docs/state-recovery.md](../docs/state-recovery.md).

## Deleting
The bucket has `prevent_destroy`, because destroying it would lose every environment's state. To tear it down deliberately, empty the bucket (all versions), remove that `lifecycle` block, then destroy.

## Use it
```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # then set alert_email; the file is git-ignored
terraform init
terraform plan -out=tfplan
terraform show tfplan                          # read it
terraform apply tfplan
terraform output backend_config_example        # paste into an environment's backend.hcl
```

## Test without AWS
```bash
terraform -chdir=bootstrap test
```
The tests mock the AWS provider, so they need no credentials.
