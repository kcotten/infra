# Solution 03: for_each over unknown values

## Root cause
`random_pet.team[*].id` is not known until `apply`, because the names are generated at that point. Using those IDs as the `for_each` keys meant Terraform could not tell, at plan time, how many `local_file` instances to create or what to call them.

## Fix
Build a map whose **keys** are known now and whose **values** may be unknown:

```hcl
for_each = { for index, pet in random_pet.team : "member-${index}" => pet.id }
```

The keys (`member-0`, `member-1`, `member-2`) come from the index. The pet names stay as values, which Terraform can resolve at apply.

## Rule of thumb
For `for_each`, keys must be known at plan time. Values need not be. Never derive keys from an attribute the provider computes.

## Why `validate` passed
`validate` checks structure only. Unknown values are a planning concern.

## Diagnosing it faster
Read the second paragraph of the error: it suggests exactly this pattern.
