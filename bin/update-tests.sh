#!/usr/bin/env bash

# This script will update spago.yaml of all test examples
# using the master files from the pre-compiled project.

set -o pipefail
set -u

base_dir=$(builtin cd "${BASH_SOURCE%/*}/.." || exit; pwd)

for config in "${base_dir}"/tests/*/spago.yaml; do
    exercise_dir=$(dirname "${config}")
    slug=$(basename "${exercise_dir}")

    echo "Working in ${exercise_dir}..."

    # Test examples use a minimal dependency set, not the full pre-compiled one.
    # Only update if the test's spago.yaml workspace section needs to change.
done
