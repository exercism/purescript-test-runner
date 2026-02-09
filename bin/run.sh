#!/usr/bin/env bash

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: absolute path to solution folder
# $3: absolute path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at
# https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/

set -o pipefail
set -u

# If required arguments are missing, print the usage and exit
if [ $# != 3 ]; then
    echo "usage: ./bin/run.sh exercise-slug /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/"
    exit 1
fi

# Establish the base directory so we can build fully-qualified directories.
base_dir=$(builtin cd "${BASH_SOURCE%/*}/.." || exit; pwd)

slug=${1}
input_dir=${2}
output_dir=${3}
results_file="${output_dir}/results.json"

# Under Docker the build directory is mounted as a read-write tmpfs so that:
# - We can work with a write-able file-system
# - We avoid copying files between the docker host and client giving a nice speedup.
build_dir=/tmp/build

if [ ! -d "${input_dir}" ]; then
    echo "No such directory: ${input_dir}"
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

# Prepare build directory
if [ -d "${build_dir}" ]; then
    rm -rf ${build_dir}
fi

mkdir -p ${build_dir}
pushd "${build_dir}" > /dev/null || exit

# Put the spago project in place: copy and rewrite the package name to match
# the pre-compiled lockfile so we can use --pure mode (no registry access).
sed 's/^  name: .*/  name: pre-compiled/' "${input_dir}/spago.yaml" > spago.yaml
ln -s "${input_dir}"/src .
ln -s "${input_dir}"/test .

# Setup our prepared node setup.
ln -s "${base_dir}/pre-compiled/node_modules" .

# The timestamps of the `output/` directory must be preserved or else
# PureScript compiler (`purs`) will invalidate the cache and force a rebuild
# defeating pre-compiling altogether (and thus the usage of the `cp` `-p`
# flag).
cp -R -p "${base_dir}/pre-compiled/output" .
cp -R "${base_dir}/pre-compiled/.spago" .
cp "${base_dir}/pre-compiled/spago.lock" .

echo "Build and test ${slug} in ${build_dir}..."

# Run the tests for the provided implementation file and redirect stdout and
# stderr to capture it.
# --offline --pure: use cached packages and lockfile, no registry/network access
# HOME=/tmp: Spago's SQLite cache needs a writable directory (Docker runs --read-only)
spago_output=$(HOME=/tmp npx spago test --offline --pure 2>&1)
exit_code=$?

popd > /dev/null || exit

# Write the results.json file based on the exit code of the command that was
# just executed that tested the implementation file.
if [ $exit_code -eq 0 ]; then
    jq -n '{version: 1, status: "pass"}' > "${results_file}"
else
    # Sanitize output: remove spago/build preamble and noise, keep compiler
    # errors and test failure output. Strip JS stack traces from test failures.
    sanitized_spago_output=$(echo "${spago_output}" | sed -E \
      -e '/^Reading Spago workspace/d' \
      -e '/^✓ Selecting package/d' \
      -e '/^Checking dependencies/d' \
      -e '/^Downloading dependencies/d' \
      -e '/^No lockfile found/d' \
      -e '/^Lockfile written/d' \
      -e '/^Building\.\.\./d' \
      -e '/^\[[[:space:]]*[0-9]+ of [0-9]+\] Compiling /d' \
      -e '/^✓ Build succeeded/d' \
      -e '/^Running tests for package/d' \
      -e '/^✘ Tests failed/d' \
      -e '/^✘ Failed to build/d' \
      -e '/^[[:space:]]+Src[[:space:]]+Lib[[:space:]]+All/d' \
      -e '/^Warnings[[:space:]]+[0-9]/d' \
      -e '/^Errors[[:space:]]+[0-9]/d' \
      -e '/^[[:space:]]+at .*(\.js|\.mjs|node:internal).*:[0-9]/d' \
      -e '/^\[WARNING /,/^$/d')

    # Remove leading/trailing blank lines and collapse runs of 3+ blank lines
    sanitized_spago_output=$(printf '%s\n' "${sanitized_spago_output}" | awk '
        { a[NR] = $0 }
        END {
            # Find first and last non-empty lines
            s = 1; e = NR
            while (s <= NR && a[s] == "") s++
            while (e >= s && a[e] == "") e--
            # Print, collapsing runs of 3+ blank lines to 2
            blank = 0
            for (i = s; i <= e; i++) {
                if (a[i] == "") { blank++; if (blank <= 2) print a[i] }
                else { blank = 0; print a[i] }
            }
        }
    ')

    jq --null-input --arg output "${sanitized_spago_output}" '{version: 1, status: "fail", message: $output}' > "${results_file}"
fi

echo "Done"
