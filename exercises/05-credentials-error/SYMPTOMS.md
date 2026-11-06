# Exercise 05: Credentials error

## Goal
Get `terraform plan` to run and report the AWS account ID. (You do not need to change anything in AWS.)

## Symptoms
- `terraform init` and `terraform validate` succeed.
- `terraform plan` stops with `Planning failed` and an `Error` naming a *profile*.
- The error points at the `provider "aws"` block, not at any resource.
- Setting `AWS_PROFILE=default` in your shell, which works for the AWS CLI, makes no difference.
- `aws sts get-caller-identity` works fine on the same machine.

## Hints
<details><summary>Hint 1: who is complaining</summary>

The message comes from the AWS provider while it sets itself up, before any resource is read. Ask what the provider was told to look for.
</details>

<details><summary>Hint 2: compare with the CLI</summary>

Run `aws configure list-profiles` and compare the names with what the configuration asks for.
</details>

<details><summary>Hint 3: precedence</summary>

Settings in the provider block outrank environment variables, which is why changing `AWS_PROFILE` did nothing. Decide whether a profile name belongs hard-coded in the configuration at all.
</details>
