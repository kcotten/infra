# Experiment: 02-starter-module

## Objective
Use the `greeting` module with `for_each`, then change it and watch the plan.

## Things to try
- Add a third entry to `local.greetings` and read the plan before applying.
- Rename a key and see which resources are destroyed and recreated.
- Set `name` to an upper-case value and read the validation error.
- Run `terraform state list` after applying to see how module addresses look.

## How to run
```bash
make init    DIR=experiments/02-starter-module
make plan    DIR=experiments/02-starter-module
make apply   DIR=experiments/02-starter-module
make destroy DIR=experiments/02-starter-module
```

## Cost
None (local providers only).
