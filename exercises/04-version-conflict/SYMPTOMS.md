# Exercise 04: Version conflict

## Goal
Get `terraform init` to succeed.

## Symptoms
- `terraform init` downloads one provider successfully, then fails on another.
- The error is `Failed to query available provider packages` and says no available releases match "the given constraints".
- Two constraints are printed, separated by a comma, and both belong to the same provider.
- Deleting `.terraform/` and trying again changes nothing.

## Hints
<details><summary>Hint 1: reading the message</summary>

Each comma-separated constraint came from a different place in the configuration. Terraform needs a single version that satisfies all of them.
</details>

<details><summary>Hint 2: a tool that helps</summary>

Run `grep -rn "version" --include=*.tf .` to list every constraint. After a successful init, `terraform providers` shows which module asked for what.
</details>

<details><summary>Hint 3: nearly the answer</summary>

Look inside `modules/namer`. Then think about which side, the root or the module, should decide the provider version.
</details>
