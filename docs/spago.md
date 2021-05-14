# Sandboxing spago

The Exercism test-runner runs solutions submitted by students in a sandboxed
environment (docker container). By design there is no network connectivity and
the root file-system is mounted read-only. PureScript's package manager and
build tool, `spago` can be run in such an environment but we need to understand
a bit more about its inner workings to overcome some limitations.

Please refer to the spago documentation for a more in depth coverage.
https://github.com/purescript/spago

## Dhall

Spago leans heavily on the Dhall configuration file format. The available
packages (package-set) specified in `packages.dhall` is retrieved from GitHub
and cached to avoid needing to re-fetch it. The Dhall libraries write to
`~/.cache/dhall` and `~/.cache/dhall-haskell`. These cache locations needs to
be writable or they will be ignored altogether and spago will attempt to
connect to GitHub to fetch the package-set. As a result we need to ensure these
cache files are available and write-able in the container.

## Global Cache

The global cache stores downloaded package dependencies to avoid having to
re-download them again. This cache is available to all spago projects and
stored under `~/.cache/spago`. An alternative cache directory can be used by
setting the `XDG_CACHE_HOME` environment variable.

    export XDG_CACHE_HOME=/tmp

For our sandboxed environment the global cache is of no use as we rely on the
local cache exclusively. We can skip the global cache entirely with the
spago `--global-cache skip` option.

## Local Cache

Downloaded package dependencies are written to the `.spago` sub-directory in
the directory where spago is invoked. If a dependency is not yet available in
the local cache the global cache will be consulted.

When spago is invoked with `run` or `test` it will write to `.spago/run.js` and
thus the local cache must be writable as well.

## Build artifacts

The PureScript compiler writes compiled modules to the `output` directory under
the directory where spago is invoked. This location can be changed by passing
an option to the compiler through spago.

    --purs-args "--output </location/output>"

For our sandboxed setup we pre-populate the `output` directory with compiled
modules to avoid having to build these with each invocation. This directory
needs to be writable to write out compiled modules. It is important to know
that the PureScript compiler (`purs`) will invalidate the cache if the
timestamps of the files in the output directory have changed.
