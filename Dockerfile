# Use the latest LTS version of Node.js
FROM node:20-bullseye-slim

# Update package lists and install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    jq \
    libncurses5 \
  && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /opt/test-runner/pre-compiled

# Copy and install dependencies
COPY pre-compiled .
RUN npm install && npx spago install && npx spago build --deps-only

# Set up bin directory
WORKDIR /opt/test-runner/bin
COPY bin/run.sh bin/run-tests.sh ./

# Ensure scripts have execution permissions
RUN chmod +x /opt/test-runner/bin/*.sh

# Set the entry point
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
