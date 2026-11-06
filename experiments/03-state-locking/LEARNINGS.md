# Learnings: 03-state-locking

## Objective
Confirm S3 native locking blocks concurrent runs (REQ-006).

## Outcome
Confirmed on 2026-11-05. While one `terraform apply` held the lock (a 45-second `sleep`):
- A `terraform.tfstate.tflock` object appeared next to the state object in the bucket.
- A second `terraform plan` failed straight away with `Error acquiring the state lock`.
- The error named the holder: operation `OperationTypeApply`, user `kris@kana`, Terraform 1.17.1, lock ID and creation time.
- When the apply finished, the `.tflock` object was deleted and a normal plan returned `No changes`.

## Lessons learnt
- Locking is a conditional write: the second run's attempt to create the lock object failed with HTTP 412 `PreconditionFailed`. The odd-looking S3 error is the lock working, not a bug.
- Read the `Lock Info` block before doing anything. If the holder is a run you started, wait for it; only consider `terraform force-unlock <ID>` when you are sure nothing is running.
- Even a plan takes the lock, because it refreshes state. Two shells cannot plan and apply at once.
- No DynamoDB table is needed with `use_lockfile = true` (Terraform 1.10 and later).

## Open questions
- How does `force-unlock` behave on an abandoned lock? Not yet tried (an interrupted apply would be needed to leave a stale lock).
