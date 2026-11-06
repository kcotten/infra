# infra

A Terraform project for learning best practices and debugging. You experiment in small, self-contained folders, with automated checks catching mistakes before they are committed.

The full requirements, design and task list live in [specs/infra-experiments/](specs/infra-experiments/). Conventions for working in this repository are in [CLAUDE.md](CLAUDE.md).

## Start here
The quickest way to experiment is to copy the experiment that uses the starter module.

```bash
cd experiments/02-starter-module
terraform init
terraform plan
terraform apply
terraform destroy
```

This costs nothing. It uses only the `local` and `random` providers, so it writes small text files into an `output/` folder and touches no cloud account. Each experiment's own README suggests changes to try.

## Prerequisites
- Terraform 1.10 or later (see [.tool-versions](.tool-versions)).
- For the quality checks: [uv](https://docs.astral.sh/uv/) and Go. `make setup` installs pre-commit, detect-secrets, checkov, tflint and terraform-docs, then installs the git hooks.
- `~/.local/bin` and `~/go/bin` on your `PATH`, so the hooks can find those tools.
- `make` for the shortcuts below. Every shortcut is a thin wrapper, and the plain `terraform` commands work just as well.

## What is where
| Folder | Purpose | Status |
|--------|---------|--------|
| [experiments/](experiments/) | Throwaway learning configurations, one folder each. | `01-local-smoke`, `02-starter-module`, `03-state-locking` (S3 locking demo) |
| [experiments/_template/](experiments/_template/) | Skeleton copied to start a new experiment. | Ready |
| [modules/](modules/) | Reusable modules, each with a README and tests. | [greeting](modules/greeting/) |
| [exercises/](exercises/) | Deliberately broken configurations for debugging practice, with separate solutions. | 6 exercises (5 free and local-acting, 1 creates a free AWS parameter) |
| [docs/](docs/) | [Debugging](docs/debugging.md), [state recovery](docs/state-recovery.md) and [cost](docs/costs.md) guides. | Ready (alert emails still to be seen) |
| [.github/workflows/](.github/workflows/) | Continuous integration: all checks, module tests and exercise checks. | No plan job yet |
| [scripts/](scripts/) | Helpers used by the pre-commit hooks and the exercise checker. | Ready |
| [specs/](specs/) | Requirements, design and task list. | Ready |
| [bootstrap/](bootstrap/) | Remote state bucket and US$5 budget alert (needs AWS). | Written and planned; not applied yet |
| [environments/](environments/) | `dev` and `sandbox`: configurations that own remote state in S3. | `dev` and `sandbox` applied |

To use an environment, copy its `backend.hcl.example` to `backend.hcl` (git-ignored, because it holds your account ID) and run `terraform init -backend-config=backend.hcl`. See [tasks.md](specs/infra-experiments/tasks.md) for what comes next.

## Everyday workflow

### Start a new experiment
```bash
make new-experiment NAME=03-my-idea
```
This copies `experiments/_template`. Without `make`, run `cp -r experiments/_template experiments/03-my-idea` and delete any `.terraform` folder it copied. Then edit `main.tf`, and record what you learn in `LEARNINGS.md`.

### Run an experiment
```bash
make init    DIR=experiments/03-my-idea
make plan    DIR=experiments/03-my-idea     # saves the plan to tfplan
make apply   DIR=experiments/03-my-idea     # applies exactly that saved plan
make destroy DIR=experiments/03-my-idea
```
Always read the plan before applying, and destroy when you have finished. Apply is never automated.

### Practise debugging
```bash
cp -r exercises/01-syntax-error /tmp/ex01 && cd /tmp/ex01
terraform init
```
Read the exercise's `SYMPTOMS.md`, diagnose the failure with [docs/debugging.md](docs/debugging.md), and only then look in `exercises/solutions/`. See [exercises/README.md](exercises/README.md) for the full routine. When state goes wrong, see [docs/state-recovery.md](docs/state-recovery.md).

### Check your work
```bash
make check                                  # all hooks against every file
make test                                   # terraform test for every module
make check-exercises                        # each exercise still fails as documented, each solution works
```
Once the hooks are installed, they run on every commit. Each check covers only the folders you changed, so a typical commit takes a few seconds.

| Check | Catches |
|-------|---------|
| `terraform fmt` | Inconsistent formatting |
| `terraform validate` | Invalid configuration |
| `tflint` | Common mistakes and unused declarations |
| `checkov` | Insecure cloud configuration |
| `detect-secrets` | Committed credentials |
| `terraform-docs` | Out-of-date module documentation |

### Write a module
Extract a module only once the same pattern appears in three places. Use [modules/greeting](modules/greeting/) as the model: typed and described variables, validation, outputs, a README and a `tests/` folder.

## Things that are never committed
State files, saved plans, real `*.tfvars` and credentials. The [.gitignore](.gitignore) excludes them, and the secret scanner is a second safety net. Credentials come from your environment.

## All make targets
Run `make help` for the list. The main ones are `setup`, `check`, `test`, `check-exercises`, `new-experiment`, `init`, `plan`, `apply` and `destroy`.
