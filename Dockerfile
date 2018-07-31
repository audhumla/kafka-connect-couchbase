FROM anapsix/alpine-java:jdk8

# Install kafka

ENV SCALA_VERSION="2.12" \
    KAFKA_VERSION="0.10.2.1"
ENV KAFKA_HOME=/opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}

ARG KAFKA_DIST=kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ARG KAFKA_DIST_TGZ=${KAFKA_DIST}.tgz
ARG KAFKA_DIST_ASC=${KAFKA_DIST}.tgz.asc

RUN set -x && \
    apk add --no-cache unzip curl ca-certificates gnupg jq && \
    eval $(gpg-agent --daemon) && \
    MIRROR=`curl -sSL https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred'` && \
    curl -sSLO "${MIRROR}kafka/${KAFKA_VERSION}/${KAFKA_DIST_TGZ}" && \
    curl -sSLO https://dist.apache.org/repos/dist/release/kafka/${KAFKA_VERSION}/${KAFKA_DIST_ASC} && \
    curl -sSL  https://kafka.apache.org/KEYS | gpg -q --import - && \
    gpg -q --verify ${KAFKA_DIST_ASC} && \
    mkdir -p /opt && \
    mv ${KAFKA_DIST_TGZ} /tmp && \
    tar xfz /tmp/${KAFKA_DIST_TGZ} -C /opt && \
    rm /tmp/${KAFKA_DIST_TGZ} && \
    apk del unzip curl ca-certificates gnupg

# Set env

ENV PATH=$PATH:/${KAFKA_HOME}/bin \
    CONNECT_CFG=${KAFKA_HOME}/config/connect-standalone.properties \
    CB_CONNECT_CFG=${KAFKA_HOME}/config/connector-config.properties \
    CONNECT_BIN=${KAFKA_HOME}/bin/connect-standalone.sh \
    CLASSPATH=${KAFKA_HOME}/connectors

ENV JMX_PORT=9999 \
    CONNECT_PORT=8083

EXPOSE ${JMX_PORT}
EXPOSE ${CONNECT_PORT}

# Run

WORKDIR $KAFKA_HOME
COPY target/kafka-connect-couchbase-3.3.2.jar $KAFKA_HOME/connectors
COPY docker/init.sh $KAFKA_HOME
COPY docker/start.sh $KAFKA_HOME
COPY config/connector-config.properties $KAFKA_HOME/config/ 
ENTRYPOINT "exec" "/$KAFKA_HOME/init.sh"

