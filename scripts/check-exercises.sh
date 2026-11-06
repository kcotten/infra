#!/usr/bin/env bash
# Confirm every debugging exercise still fails the way its SYMPTOMS.md promises,
# and every solution initialises, validates and plans cleanly.
#
# Usage: scripts/check-exercises.sh
# Runs in a temporary copy so no .terraform folders are left in the repository.
set -uo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly EXERCISES_DIR="${REPO_ROOT}/exercises"
readonly SOLUTIONS_DIR="${EXERCISES_DIR}/solutions"

work_dir="$(mktemp -d)"
trap 'rm -rf "${work_dir}"' EXIT

# Share downloaded providers between runs to keep this fast.
export TF_PLUGIN_CACHE_DIR="${work_dir}/plugin-cache"
mkdir -p "${TF_PLUGIN_CACHE_DIR}"

failures=0

pass() { echo "  PASS  $1"; }
fail() { echo "  FAIL  $1"; failures=$((failures + 1)); }

# Run init, validate and plan in order, stopping at the first failure.
# A directory containing a validate-only file stops after validate, because
# planning needs real AWS credentials. Its content says why.
# Leaves the combined output of the failing (or last) step in $last_output.
run_workflow() {
  local directory="$1"
  local steps=("init -backend=false -input=false" "validate")
  local step
  [ -f "${directory}/validate-only" ] || steps+=("plan -input=false -lock=false")
  last_output=""
  for step in "${steps[@]}"; do
    # shellcheck disable=SC2086  # word splitting of the step is intended
    last_output="$(terraform -chdir="${directory}" ${step} -no-color 2>&1)" || return 1
  done
  return 0
}

copy_to_work_dir() {
  local source="$1" label="$2"
  rm -rf "${work_dir:?}/${label}"
  cp -r "${source}" "${work_dir}/${label}"
  echo "${work_dir}/${label}"
}

check_exercise() {
  local name="$1"
  local source="${EXERCISES_DIR}/${name}"
  local expected_file="${source}/expected-error.txt"

  local required_files=(SYMPTOMS.md main.tf)
  # A validate-only exercise cannot fail offline, so it has no expected error.
  [ -f "${source}/validate-only" ] || required_files+=(expected-error.txt)
  for required in "${required_files[@]}"; do
    [ -f "${source}/${required}" ] || { fail "${name}: missing ${required}"; return; }
  done
  [ -f "${SOLUTIONS_DIR}/${name}/SOLUTION.md" ] || { fail "${name}: missing solutions/${name}/SOLUTION.md"; return; }

  local expected copy
  copy="$(copy_to_work_dir "${source}" "exercise-${name}")"

  if [ -f "${source}/validate-only" ]; then
    if run_workflow "${copy}"; then
      pass "${name}: validates (live steps are run by hand: $(head -n 1 "${source}/validate-only"))"
    else
      fail "${name}: does not validate"
      echo "${last_output}" | head -n 15 | sed 's/^/        /'
    fi
    return
  fi

  expected="$(head -n 1 "${expected_file}")"

  if run_workflow "${copy}"; then
    fail "${name}: expected a failure but the exercise worked"
  elif grep -qF -- "${expected}" <<<"${last_output}"; then
    pass "${name}: fails with \"${expected}\""
  else
    fail "${name}: failed, but not with \"${expected}\""
    echo "${last_output}" | head -n 15 | sed 's/^/        /'
  fi
}

check_solution() {
  local name="$1"
  local copy
  copy="$(copy_to_work_dir "${SOLUTIONS_DIR}/${name}" "solution-${name}")"

  if run_workflow "${copy}"; then
    if [ -f "${copy}/validate-only" ]; then
      pass "solutions/${name}: initialises and validates (plan needs AWS)"
    else
      pass "solutions/${name}: initialises, validates and plans"
    fi
  else
    fail "solutions/${name}: does not work"
    echo "${last_output}" | head -n 15 | sed 's/^/        /'
  fi
}

echo "Exercises (each must fail as documented):"
for source in "${EXERCISES_DIR}"/[0-9][0-9]-*/; do
  check_exercise "$(basename "${source}")"
done

echo "Solutions (each must work):"
for source in "${SOLUTIONS_DIR}"/[0-9][0-9]-*/; do
  check_solution "$(basename "${source}")"
done

echo
if [ "${failures}" -eq 0 ]; then
  echo "All exercise checks passed."
else
  echo "${failures} exercise check(s) failed."
  exit 1
fi
