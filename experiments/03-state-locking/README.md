# Experiment: 03-state-locking

## Objective
Prove that the S3 backend's native locking stops two runs changing the same state at once (REQ-006).

## Setup
Uses only the built-in `terraform_data` resource, so it creates nothing in AWS except this experiment's state object.

```bash
cd experiments/03-state-locking
terraform init \
  -backend-config=../../environments/dev/backend.hcl \
  -backend-config="key=experiments/03-state-locking/terraform.tfstate"
```
The second `-backend-config` overrides the `key` from the file, so this experiment has its own state.

## The test
1. In shell 1: `terraform apply` (holds the lock for `hold_seconds`, 45 by default).
2. While it runs, in shell 2: `terraform plan`.
3. Expect `Error: Error acquiring the state lock` with a `Lock Info` block naming the holder. The underlying S3 error is `412 PreconditionFailed`; that is the lock working.
4. While it runs, list the lock object: `aws s3 ls s3://<bucket>/experiments/03-state-locking/`. A `.tflock` object sits beside the state.
5. After shell 1 finishes, run `terraform plan` again. It now works, and the `.tflock` object is gone.

## Clean up
```bash
terraform destroy
```
The empty state object stays in the bucket, as a record that the experiment ran.

## Cost
None.
