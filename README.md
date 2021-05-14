# Exercism PureScript Test Runner

The Docker image for automatically run tests on PureScript solutions submitted
to [exercism][web-exercism].

This repository contains the PureScript test runner, which implements the
[test runner interface][test-runner-interface].


## Running the Tests in Docker container

To run a solution's test in the Docker container, do the following:
1. Open terminal in project's root
2. Run `./run-in-docker.sh <exercise> <solution-folder> <output-folder>`

[test-runner-interface]: https://github.com/exercism/automated-tests/blob/master/docs/interface.md
[web-exercism]: https://exercism.io/


## Design Goal and Implementation

Due to the sandboxed environment we need to prepare everything we need in
advance. All the PureScript packages that may be used for a solution are
downloaded and pre-compiled. To make this happen we've setup a basic spago
project under `./pre-compiled`. Note that the package-set set in
`packages.dhall` must correspond with the one used by in the exercises
repository (exercism/purescript). This directory is copied into the Docker
image and from there all dependencies are installed and compiled. All the
necessary bits are then available to be used by `bin/run.sh` to setup a spago
project to build the submitted solution.

The `bin/run.sh` script will piece together a spago project to build and test
the submitted solution. The project is built under `/tmp/build` which is
mounted as a `tmpfs` which is required for write-access. A `tmpfs` is also
speedier than reading from or writing to a `bind` mount. See `docs/spago.md`
for more details on running spago in a sandbox.
