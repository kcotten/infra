# State recovery

Terraform's state maps your configuration to real objects. When the two disagree, or state is lost, these tools restore the link.

## What has been practised
Sections marked **Practised** were run with local state in a scratch project using the `random` and `local` providers, and the output described here was observed. Sections marked **Not yet practised** need the S3 backend from the bootstrap step (TASK-006) and will be tried and updated in the state-locking experiment (TASK-010). Do not rely on those until then.

## Golden rules
1. **Back up first.** `terraform state pull > state-backup.json` before any state surgery. (Local state also keeps a `terraform.tfstate.*.backup` file after each change.)
2. **Read the plan afterwards.** The goal of every operation below is a plan that says `No changes`.
3. **Prefer declarative tools** (`moved` and `import` blocks) to commands. They appear in code review and can be replayed.
4. **Never edit the state file by hand** unless every other option has failed.

## Practised

### Rename or move a resource: `moved` block (preferred)
```hcl
moved {
  from = random_integer.die
  to   = random_integer.dice
}
```
With the configuration renamed, `terraform plan` reports `random_integer.die has moved to random_integer.dice` and `0 to add, 0 to change, 0 to destroy`. Keep the block until every environment has applied it.

### Rename or move a resource: `terraform state mv`
```bash
terraform state mv random_integer.dice random_integer.die
```
**Order matters.** Moving state without also renaming the resource in the configuration gives a plan that destroys one and creates another (observed: `2 to add, 0 to change, 2 to destroy`). Rename in the configuration too, then the plan reads `No changes`.

### Stop tracking a resource: `terraform state rm`
```bash
terraform state rm random_integer.die
```
The real object is untouched. Terraform just forgets it. The next plan wants to **create** it again, and anything depending on it may be **replaced**. In the practice run, the file that used the dice result had to be replaced because a new dice roll would change its content. Use this when handing a resource to another configuration or when it should no longer be managed.

### Adopt an existing object: `terraform import`
```bash
terraform import random_integer.die "2,1,6"
```
Each resource type has its own ID format, which is documented on the provider's registry page. After importing, the plan read `No changes`, because the configuration already described the object.

### Adopt an existing object: `import` block (preferred, Terraform 1.5+)
```hcl
import {
  to = random_integer.die
  id = "2,1,6"
}
```
`terraform plan` shows `1 to import`, and `apply` performs it. Remove the block afterwards.

### Recover from lost state
1. Deleting the state files made the next plan say `2 to add`: Terraform believed nothing existed. **Do not apply that plan** for real infrastructure, as it would try to create duplicates.
2. Write `import` blocks for each real object, run `plan`, and check each shows `will be imported`.
3. Apply, then confirm the next plan is `No changes`.

### Not every resource can be imported
`local_file` cannot: `terraform import` returns `Resource Import Not Implemented`. Check the provider documentation before relying on import as a recovery path. If a resource has no import, the options are to recreate it or to recreate its state with the provider's other data.

### Force one resource to be recreated
```bash
terraform plan -replace=random_integer.dice
```
Use `-replace` instead of the old `terraform taint`.

## Not yet practised (needs the S3 backend)

### Restore an earlier state version
The state bucket will be versioned. To roll back: list versions of the state object, copy the wanted version over the current one, then run `terraform plan` and check it. Procedure and exact commands will be recorded after the TASK-010 experiment.

### Stuck lock
**What a lock looks like (practised, experiment 03-state-locking):** while a run holds the lock, a `terraform.tfstate.tflock` object sits beside the state in the bucket. A second run fails at once with `Error acquiring the state lock`, an underlying `412 PreconditionFailed`, and a `Lock Info` block giving the lock ID, operation, who holds it and when it was taken. When the first run finishes, the lock object is removed.

**Releasing a stale lock (not yet practised):** if a run was killed, the lock may remain. `terraform force-unlock <LOCK_ID>` removes it. Only do this after confirming nobody else is running Terraform against that state. Reproducing a genuinely stale lock safely is still to be tried.

### Bootstrap state lost
The bootstrap configuration keeps its own state **locally** (it creates the bucket, so it cannot use it). That file is git-ignored and backed up by hand. If it is lost, re-import the bucket and its settings into a fresh bootstrap state using `import` blocks, then confirm the plan reads `No changes`. Will be practised when the bootstrap exists.

## Quick decision guide
| Situation | Use |
|-----------|-----|
| Renamed a resource in the code | `moved` block |
| Resource exists but Terraform does not manage it | `import` block |
| Terraform should stop managing a resource, but not delete it | `terraform state rm` |
| One resource is misbehaving and should be rebuilt | `terraform plan -replace=...` |
| State file is gone | Back up whatever remains, then `import` blocks, never a blind apply |
| Plan disagrees with reality and you want to see why | `terraform plan -refresh-only` |
