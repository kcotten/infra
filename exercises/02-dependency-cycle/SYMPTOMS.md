# Exercise 02: Dependency cycle

## Goal
Get `terraform validate` to succeed.

## Symptoms
- `terraform init` succeeds.
- `terraform validate` fails with `Error: Cycle:` followed by two resource addresses.
- No line number is reported, only the names of the resources involved.
- Both resources look reasonable when read one at a time.

## Hints
<details><summary>Hint 1: reading the message</summary>

The two resources listed are the ones on the loop. Terraform builds a graph in which an arrow means "must be created first". Ask what each resource needs from the other.
</details>

<details><summary>Hint 2: a tool that helps</summary>

Search `main.tf` for each resource's address, for example `local_file.backup`, and see where it is referenced. `terraform graph` can draw the graph, but here reading the references is quicker.
</details>

<details><summary>Hint 3: nearly the answer</summary>

One of the references only needs a value that is already known from the configuration. It does not need anything the other resource produces.
</details>
