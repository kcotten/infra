# Solution 01: Syntax error

## Root cause
The `random_pet` block was never closed. The parser kept reading, treated the next `resource` keyword as part of the first block, and only noticed at the end of the file that a brace was missing. That is why the error reports line 1 (where the unclosed block *starts*), not the line where the brace is missing.

## Fix
Add the missing `}` after `length = 2`.

## Why it fails at `init`
`terraform init` has to read the configuration to know which providers to install, so it fails on a syntax error before doing any work.

## Diagnosing it faster
- Read the *whole* message. "Unclosed configuration block" names the problem.
- `terraform fmt -diff` and an editor with bracket matching find this in seconds.
- The pre-commit hooks run `terraform fmt` and `terraform validate` and would catch it before you commit.
