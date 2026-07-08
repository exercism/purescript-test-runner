# node:lts-slim == node:24.18.0-bookworm-slim on 2026-07-07
FROM node:24.18.0-bookworm-slim@sha256:cb4e8f7c443347358b7875e717c29e27bf9befc8f5a26cf18af3c3dec80e58c5

# Install system dependencies:
# - ca-certificates: HTTPS support for downloading packages from the registry
# - git: required by Spago for registry index management
# - jq: used by run.sh to generate results.json output
# - libncurses5: runtime dependency for the PureScript compiler (purs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    jq \
    libncurses5 \
  && rm -rf /var/lib/apt/lists/*

# Use a single WORKDIR for the test runner root
WORKDIR /opt/test-runner

# Install PureScript dependencies and pre-compile them.
# The output/ and .spago/ directories are reused at runtime to avoid
# recompiling 280+ modules for every student submission.
COPY pre-compiled pre-compiled/
RUN cd pre-compiled \
  && npm install \
  && npx spago install \
  && npm cache clean --force \
  && rm -rf /root/.npm

# Copy runner scripts
COPY bin/run.sh bin/run-tests.sh bin/
RUN chmod +x bin/*.sh

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
