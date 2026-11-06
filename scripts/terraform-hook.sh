#!/usr/bin/env bash
# Run one Terraform quality check against the directories containing the changed files.
#
# Usage: scripts/terraform-hook.sh <fmt|validate|tflint|docs|scan> <changed file>...
# Only changed directories are checked so pre-commit stays fast.
set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check_name="${1:?Usage: $0 <fmt|validate|tflint|docs|scan> <file>...}"
shift

changed_directories() {
  printf '%s\n' "$@" | xargs -r -n1 dirname | sort -u
}

run_fmt() {
  terraform fmt -check -diff "$1"
}

run_validate() {
  # Use a throwaway data directory so validating never overwrites the backend
  # settings of a directory the learner has already initialised for real.
  local data_dir
  data_dir="$(mktemp -d)"
  TF_DATA_DIR="${data_dir}" terraform -chdir="$1" init -backend=false -input=false -no-color >/dev/null \
    && TF_DATA_DIR="${data_dir}" terraform -chdir="$1" validate -no-color
  local status=$?
  rm -rf "${data_dir}"
  return "${status}"
}

run_tflint() {
  tflint --config="${REPO_ROOT}/.tflint.hcl" --chdir="$1"
}

run_docs() {
  # Only modules carry generated documentation, and only once their README has the markers.
  case "$1" in
    modules/*) ;;
    *) return 0 ;;
  esac
  if grep -q "BEGIN_TF_DOCS" "$1/README.md" 2>/dev/null; then
    terraform-docs markdown table --output-file README.md --output-mode inject "$1" >/dev/null
  fi
}

run_scan() {
  checkov --directory "$1" --framework terraform --quiet --compact
}

status=0
while IFS= read -r directory; do
  [ -d "$directory" ] || continue
  ls "$directory"/*.tf >/dev/null 2>&1 || continue
  echo "== ${check_name}: ${directory}"
  "run_${check_name}" "$directory" || status=1
done < <(changed_directories "$@")

exit "$status"
