# Common workflows for infra-experiments.
# Usage: make help

SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

# Set these on the command line, e.g. DIR=experiments/01-local-smoke.
# Plain '=' (not '?=') so stray DIR or NAME environment variables are ignored.
DIR =
NAME =

.PHONY: help
help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Install quality tools and the git hooks (needs uv and go; add ~/.local/bin and ~/go/bin to PATH)
	uv tool install pre-commit
	uv tool install detect-secrets
	uv tool install checkov
	go install github.com/terraform-linters/tflint@latest
	go install github.com/terraform-docs/terraform-docs@latest
	pre-commit install

.PHONY: check
check: ## Run every pre-commit check against all files
	pre-commit run --all-files

.PHONY: test
test: ## Run terraform test for every module and the bootstrap (no AWS needed)
	@for module in modules/*/ bootstrap/; do \
		[ -d "$$module/tests" ] || continue; \
		echo "== $$module"; \
		terraform -chdir=$$module init -input=false >/dev/null && terraform -chdir=$$module test || exit 1; \
	done

.PHONY: check-exercises
check-exercises: ## Confirm each exercise fails as documented and each solution works
	scripts/check-exercises.sh

.PHONY: new-experiment
new-experiment: ## Create an experiment from the template (NAME=01-my-experiment)
	@test -n "$(NAME)" || { echo "NAME is required, e.g. make new-experiment NAME=01-my-experiment"; exit 1; }
	@test ! -e experiments/$(NAME) || { echo "experiments/$(NAME) already exists"; exit 1; }
	cp -r experiments/_template experiments/$(NAME)
	rm -rf experiments/$(NAME)/.terraform
	@echo "Created experiments/$(NAME)"

.PHONY: init
init: _require-dir ## terraform init in DIR
	terraform -chdir=$(DIR) init

.PHONY: plan
plan: _require-dir ## terraform plan in DIR, saving the plan to DIR/tfplan
	terraform -chdir=$(DIR) plan -out=tfplan

.PHONY: apply
apply: _require-dir ## Apply the saved plan in DIR
	terraform -chdir=$(DIR) apply tfplan

.PHONY: destroy
destroy: _require-dir ## Destroy everything in DIR
	terraform -chdir=$(DIR) destroy

.PHONY: _require-dir
_require-dir:
	@test -n "$(DIR)" || { echo "DIR is required, e.g. make plan DIR=experiments/01-local-smoke"; exit 1; }
	@test -d "$(DIR)" || { echo "Directory '$(DIR)' does not exist"; exit 1; }
