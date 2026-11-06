# Exercise 06: State drift

> **This exercise creates one real AWS resource.** It is a standard-tier Parameter Store parameter, which has no storage charge, but treat it like any cloud resource and destroy it at the end.

## Goal
Understand why Terraform wants to change something you did not touch, and bring the code and AWS back into agreement.

## Setup
Work in a copy so the original stays untouched, and use your own credentials:
```bash
cp -r exercises/06-state-drift /tmp/ex06 && cd /tmp/ex06
terraform init
terraform apply          # read the plan first; it creates one parameter
./break.sh               # simulates someone editing it by hand
```

## Symptoms
- No code has changed since `apply`.
- `terraform plan` nevertheless proposes a change to the parameter.
- The change is to something you set in the configuration.
- `terraform apply` would make the proposed change, silently undoing someone's edit.

## Hints
<details><summary>Hint 1: what changed, and where</summary>

Read what the plan proposes to change, then ask who last changed it. Terraform compares three things: your code, its state, and what AWS reports. Which two differ?
</details>

<details><summary>Hint 2: look at the real object</summary>

`terraform state show aws_ssm_parameter.greeting` shows what Terraform last recorded. `aws ssm list-tags-for-resource --region us-west-1 --resource-type Parameter --resource-id /infra-experiments/exercise-06/greeting` shows what is there now.
</details>

<details><summary>Hint 3: your options</summary>

There is more than one valid resolution, depending on whose change should win:
- the code should win,
- the manual change should be adopted into the code,
- or the manual change is expected and should be ignored.

Decide first, then act. `terraform plan -refresh-only` shows drift without proposing any code changes.
</details>

## Clean up
```bash
terraform destroy
```
