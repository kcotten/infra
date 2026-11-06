# Solution 06: State drift

## Root cause
Someone (here, `break.sh`) changed a tag on the parameter in AWS directly. Terraform's next `plan` refreshes its view of the real object, sees that the tag no longer matches the configuration, and proposes to put it back. This is **drift**: the real world moved away from the code.

## Choose who wins, then act
| Situation | Action |
|-----------|--------|
| The code is right | `terraform apply`. It reverts the manual change. |
| The manual change was right | Edit the configuration to match (here, change the `Purpose` tag), then `plan` should read `No changes`. |
| The manual change is expected and should be left alone | Add `lifecycle { ignore_changes = [tags["Purpose"]] }` (or the whole `tags`) to the resource, and write down why. |

## What `-refresh-only` is for
`terraform plan -refresh-only` shows drift without proposing to change the infrastructure, and `terraform apply -refresh-only` records the new reality in state. It does **not** change your code, so if the code still disagrees, the next ordinary plan will propose the change again.

## Why it happens, and how to limit it
- People use the console to "just fix" something under pressure.
- Other automation edits the same resource.
- The best defence is to limit who can change infrastructure by hand, and to run `plan` regularly so drift is found early and small.

## Note on automated checking
Reproducing drift needs a real AWS resource, so `make check-exercises` only validates this exercise and its solution. The drift itself is something you run by hand, following the setup in `SYMPTOMS.md`.
