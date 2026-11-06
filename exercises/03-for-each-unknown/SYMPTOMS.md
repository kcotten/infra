# Exercise 03: for_each over unknown values

## Goal
Get `terraform plan` to succeed and show three badge files to be created.

## Symptoms
- `terraform init` and `terraform validate` both succeed.
- `terraform plan` starts printing the plan, then fails with `Error: Invalid for_each argument`.
- The message mentions values that "cannot be determined until apply".
- Changing `count = 3` to a smaller number does not help.

## Hints
<details><summary>Hint 1: why validate passed</summary>

`validate` only checks that the configuration makes sense. It does not know what values the resources will produce. Only `plan` does.
</details>

<details><summary>Hint 2: what is unknown</summary>

Ask where the values in the `for_each` set come from. When are those values decided?
</details>

<details><summary>Hint 3: nearly the answer</summary>

Terraform needs to know the *keys* of a `for_each` collection at plan time. It does not need to know the *values*. A map lets you choose the two separately.
</details>
