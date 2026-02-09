#!/usr/bin/env bash

# This script will update the workspace section of all test examples'
# spago.yaml to match the pre-compiled project's workspace configuration
# (package set version, extra packages).

set -o pipefail
set -u

base_dir=$(builtin cd "${BASH_SOURCE%/*}/.." || exit; pwd)

# Extract the workspace section from pre-compiled/spago.yaml
workspace_section=$(sed -n '/^workspace:/,$p' "${base_dir}/pre-compiled/spago.yaml")

for config in "${base_dir}"/tests/*/spago.yaml; do
    exercise_dir=$(dirname "${config}")
    slug=$(basename "${exercise_dir}")

    echo "Working in ${exercise_dir}..."

    # Replace the workspace section (everything from "workspace:" to EOF)
    package_section=$(sed -n '1,/^workspace:/{ /^workspace:/!p; }' "${config}")
    printf '%s\n%s\n' "${package_section}" "${workspace_section}" > "${config}"
done
