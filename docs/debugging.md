# Debugging Terraform

A toolkit for working out *why* Terraform is doing something. Every command below was run against this repository's tooling (Terraform 1.17.1) while writing this guide. Practise on the [exercises](../exercises/).

## First, find out which stage failed
Terraform fails at different stages, and the stage is the first clue.

| Stage | Command | Typical problems |
|-------|---------|------------------|
| Parse | `terraform init` | Syntax errors, unreadable configuration |
| Install | `terraform init` | Provider or module version conflicts, network problems |
| Validate | `terraform validate` | Unknown attributes, wrong types, dependency cycles |
| Plan | `terraform plan` | Values unknown until apply, `for_each` problems, provider authentication |
| Apply | `terraform apply` | Provider API errors, permissions, quotas, drift |

`validate` only checks structure. It does not know what a resource will produce, so a configuration can validate and still fail at plan (see [exercise 03](../exercises/03-for-each-unknown/)).

## Read the error properly
1. Read the **whole** message, including the last paragraph, where Terraform often suggests the fix.
2. The reported line is where the problem was *noticed*. The cause may be earlier (see [exercise 01](../exercises/01-syntax-error/)).
3. Copy the first line of the error, not the last, into a search.

## Tools

### Formatting and validation
```bash
terraform fmt -diff                  # show what formatting would change
terraform validate                   # structural check
terraform validate -json             # machine-readable, useful in scripts
```

### Inspect a plan before applying it
```bash
terraform plan -out=tfplan           # save exactly what was planned
terraform show tfplan                # read it again later
terraform show -json tfplan          # full detail for tooling
terraform apply tfplan               # apply exactly that plan
```
Saved plans can contain secrets. They are git-ignored; never commit them.

### Evaluate expressions: `terraform console`
```bash
echo 'upper("debug me")' | terraform console
echo 'random_integer.dice.result + 100' | terraform console
```
The console reads real state, so it can evaluate expressions against existing resources. Use it to test `for` expressions and functions before putting them in a file.

### See what Terraform and the providers are doing: logging
```bash
TF_LOG=INFO  terraform plan                       # core summary
TF_LOG=TRACE terraform plan                       # everything (very verbose)
TF_LOG_PATH=./tf.log TF_LOG=DEBUG terraform plan  # write to a file instead
TF_LOG_CORE=WARN TF_LOG_PROVIDER=TRACE terraform plan   # quiet core, chatty provider
```
Levels from quietest to loudest: `ERROR`, `WARN`, `INFO`, `DEBUG`, `TRACE`.
- Use `TF_LOG_PROVIDER=TRACE` for provider API failures, where requests and responses are logged.
- Use `TF_LOG_PATH`, then search the file. Terminal output at `TRACE` is hard to read.
- Logs can contain credentials. Review them before sharing, and never commit them (`*.log` files from crashes are git-ignored).

### Understand dependencies
```bash
terraform graph                      # text in DOT format
terraform graph | dot -Tsvg > graph.svg   # draw it (needs Graphviz, which is not installed here)
```
An arrow means "depends on". For a short cycle, searching for the resource addresses in the error is quicker (see [exercise 02](../exercises/02-dependency-cycle/)).

### Inspect providers and state
```bash
terraform providers                  # which providers each module requires
terraform state list                 # everything Terraform is tracking
terraform state show <address>       # attributes of one resource
```

### Force a different outcome, carefully
```bash
terraform plan -replace=<address>    # plan to destroy and recreate one resource
terraform plan -refresh-only         # compare state with reality without proposing config changes
terraform plan -target=<address>     # limit to one resource: a debugging aid, not a workflow
```
`-target` skips the dependency graph's full picture. Use it to investigate, not to ship.

## A systematic approach
1. **Reproduce** it with the smallest configuration that still fails. Copy it to a scratch folder and delete things until the problem disappears.
2. **Find the stage** (table above).
3. **Read** the full message, then search for the first line.
4. **Look at real values** with `console`, `state show` and `show tfplan`, not what you assume them to be.
5. **Turn up logging** only when the message is not enough.
6. **Change one thing at a time**, re-running the same command.
7. **Write down** the cause and the fix in the experiment's `LEARNINGS.md`.

## Where state is involved
See [state-recovery.md](state-recovery.md) for `state mv`, `state rm`, `import` and what to do when state is lost.
