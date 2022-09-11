#!/usr/bin/env bash

# This script will update spago.dhall and package.dhall of all exercises
# using the master files from the project template (pre-compiled/).

set -o pipefail
set -u

base_dir=$(builtin cd "${BASH_SOURCE%/*}/.." || exit; pwd)
project_dir="${base_dir}/pre-compiled"

for config in ./tests/*/spago.dhall; do
    exercise_dir=$(dirname "${config}")
    # slug=$(basename "${exercise_dir}")

    echo "Working in ${exercise_dir}..."

    # sed -e "s/pre-compiled/${slug}/" < "${project_dir}/spago.dhall" > "${exercise_dir}/spago.dhall"
    cp "${project_dir}/packages.dhall" "${exercise_dir}/packages.dhall"
done
