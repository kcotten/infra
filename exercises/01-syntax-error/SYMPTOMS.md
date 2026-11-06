# Exercise 01: Syntax error

## Goal
Get `terraform init` to succeed.

## Symptoms
- `terraform init` stops immediately, before downloading any providers.
- The error says the configuration "must be valid before initialization".
- `terraform validate` and `terraform plan` cannot run either.
- The error points at line 1 of `main.tf`, which looks fine on its own.

## Hints
<details><summary>Hint 1: where to look</summary>

The reported line is where the problem was *noticed*, which is not always where it was *caused*. Read the whole message, including the last sentence.
</details>

<details><summary>Hint 2: a tool that helps</summary>

Run `terraform fmt -diff`. Formatting often goes visibly wrong near a syntax problem. Better still, check that every block you open is closed.
</details>

<details><summary>Hint 3: nearly the answer</summary>

Count the opening and closing braces in `main.tf`.
</details>
