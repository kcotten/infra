# Debugging exercises

Each exercise is a small configuration with one deliberate fault. Your job is to find the cause and fix it using only Terraform's own output and the tools in [docs/debugging.md](../docs/debugging.md). Everything here uses the `local` and `random` providers, so it costs nothing.

| Exercise | Fault category | Fails at |
|----------|----------------|----------|
| [01-syntax-error](01-syntax-error/) | Syntax | `init` |
| [02-dependency-cycle](02-dependency-cycle/) | Dependency graph | `validate` |
| [03-for-each-unknown](03-for-each-unknown/) | `count` / `for_each` misuse | `plan` |
| [04-version-conflict](04-version-conflict/) | Version constraints | `init` |
| [05-credentials-error](05-credentials-error/) | Provider authentication | `plan` |
| [06-state-drift](06-state-drift/) | State drift | `plan`, after a manual change |

Exercises 01 to 05 cost nothing and touch no AWS resources (05 fails before contacting AWS). **Exercise 06 creates one real, free, standard-tier AWS parameter**, so read its setup before you start.

## How to work through one
1. Copy the exercise so the original stays broken: `cp -r exercises/01-syntax-error /tmp/ex01 && cd /tmp/ex01`.
2. Read its `SYMPTOMS.md`. It describes what you will see, never the cause.
3. Run `terraform init`, `terraform validate` and `terraform plan` and diagnose the failure.
4. Open the hints one at a time, only as needed.
5. When it works, compare with `exercises/solutions/<name>/SOLUTION.md` and note what you learnt.

Keep out of `exercises/solutions/` until you have tried the exercise.

## Keeping the exercises honest
```bash
make check-exercises
```
This confirms that every exercise still fails with the error it promises and that every solution initialises, validates and plans. It runs in a temporary copy, so nothing is left behind.

Exercises that need real AWS resources carry a `validate-only` file explaining why. For those, the check only confirms the configuration validates, and you run the live steps by hand.

## Adding an exercise
Create `NN-name/` with a broken `main.tf`, `versions.tf`, `SYMPTOMS.md` and `expected-error.txt` (one line of text the failing output must contain; not needed with a `validate-only` file). Add `solutions/NN-name/` with the fixed configuration and a `SOLUTION.md`. Then run `make check-exercises`.
