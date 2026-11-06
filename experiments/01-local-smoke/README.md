# Experiment: 01-local-smoke

## Objective
Prove the init, plan, apply, destroy workflow end to end using only the `local` and `random` providers.

## How to run
```bash
make init    DIR=experiments/01-local-smoke
make plan    DIR=experiments/01-local-smoke
make apply   DIR=experiments/01-local-smoke
make destroy DIR=experiments/01-local-smoke
```

## Cost
None (local providers only).
