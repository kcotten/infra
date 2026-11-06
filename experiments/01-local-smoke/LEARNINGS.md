# Learnings: 01-local-smoke

## Objective
Confirm the workflow works at zero cost before any cloud resources are involved.

## Outcome
Apply creates `greeting.txt`; a second plan reports no changes; destroy removes the file.

## Lessons learnt
- A saved plan (`plan -out`) is applied exactly as reviewed.
- The `local` and `random` providers are enough to practise most debugging for free.

## Open questions
- None yet.
