FROM node:16-buster-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20200601~deb10u2 \
    git=1:2.20.1-2+deb10u3 \
    jq=1.5+dfsg-2+b1 \
    libncurses5=6.1+20181013-2+deb10u2 \
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
