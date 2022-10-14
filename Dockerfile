FROM node:18.9.1-bullseye-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20210119 \
    git=1:2.30.2-1 \
    jq=1.6-2.1 \
    libncurses5=6.2+20201114-2 \
  && apt-get purge --auto-remove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Pre-compile exercise dependencies
WORKDIR /opt/test-runner/pre-compiled
COPY pre-compiled .
RUN npm install && npx spago install && npx spago build --deps-only

# Setup bin directory
WORKDIR /opt/test-runner/bin
COPY bin/run.sh bin/run-tests.sh ./
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
