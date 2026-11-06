# Solution 02: Dependency cycle

## Root cause
- `local_file.primary` referenced `local_file.backup.filename`, so `backup` had to exist first.
- `local_file.backup` referenced `local_file.primary.content_md5`, so `primary` had to exist first.

Each resource waited for the other, so there was no valid order to create them in.

## Fix
`filename` is not something the backup *produces*. It is a value we chose. Move the paths into `locals` and reference those instead. The dependency from `backup` to `primary` remains, but it now points one way only.

## Why a reference to a configured value still counts
Terraform builds its graph from references, not from the nature of the value. Any mention of `local_file.backup.<anything>` creates an arrow.

## Diagnosing it faster
- The error lists exactly the resources on the loop.
- `terraform graph` draws the arrows if the loop is longer than two resources.
- Prefer `locals` for values several resources share.
