# Solution 04: Version conflict

## Root cause
The root module required `random ~> 3.6` while `modules/namer` required `random ~> 2.0`. Terraform installs one copy of each provider for the whole configuration, and no version satisfies both `3.x` and `2.x`.

## Fix
Widen the module's constraint to a range that is compatible with the root: `>= 3.6, < 4.0`.

## Who should decide the version?
- The **root module** chooses the exact provider version, and `.terraform.lock.hcl` records it.
- **Reusable modules** declare the *range* they have been tested with, so they can be used from many roots.

A module that pins tightly forces every caller to use the same version.

## Diagnosing it faster
- Each comma-separated constraint in the error came from a different `required_providers` block.
- `grep -rn "version" --include=*.tf .` lists them all.
- After a successful init, `terraform providers` shows the requirement tree.
