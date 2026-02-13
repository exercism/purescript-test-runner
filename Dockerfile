# Spago 1.0.3 requires Node.js >= 22.5.0 (uses node:sqlite built-in module)
FROM node:22-bookworm-slim

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
