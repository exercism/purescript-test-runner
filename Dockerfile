FROM node:16-buster-slim

RUN apt-get update && \
    apt-get install -y git jq libncurses5 && \
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner

ENV PATH="/opt/test-runner/node_modules/.bin:$PATH" 

COPY pre-compiled/package.json pre-compiled/package-lock.json ./
RUN npm install

COPY pre-compiled/bower.json .
RUN bower install --allow-root

COPY pre-compiled/ .
RUN pulp build

COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]