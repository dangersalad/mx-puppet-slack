FROM node:latest AS builder

WORKDIR /opt/mx-puppet-slack

COPY package.json package-lock.json ./
RUN npm install

COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build


FROM node:alpine

VOLUME /data
VOLUME /config

# su-exec is used by docker-run.sh to drop privileges
RUN apk add --no-cache su-exec

WORKDIR /opt/mx-puppet-slack
COPY docker-run.sh ./
COPY --from=builder /opt/mx-puppet-slack/node_modules/ ./node_modules/
COPY --from=builder /opt/mx-puppet-slack/build/ ./build/

# change workdir to /data so relative paths in the config.yaml
# point to the persisten volume
WORKDIR /data
ENTRYPOINT ["/opt/mx-puppet-slack/docker-run.sh"]
