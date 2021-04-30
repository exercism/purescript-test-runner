FROM node:16-buster-slim

RUN apt-get update && \
    apt-get install -y git jq libncurses5 && \
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner

# Pre-install packages
COPY package.json package-lock.json ./
RUN npm install

COPY bower.json .
RUN ./node_modules/.bin/bower install --allow-root

# TODO: pre-compile standard library and copy output directory in run.sh

COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]