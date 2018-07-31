#!/usr/bin/env bash

CONTAINER_IP=$(tail -1 /etc/hosts | awk '{print $1}')

#Setting environment variables for connector - kafka part
sed -i "s/localhost/$CONTAINER_IP/" $CONNECT_CFG

# Setting environment variables for connector - couchbase part
sed -i "s/@COUCHBASE_NODES@/$COUCHBASE_NODES/" $CB_CONNECT_CFG
sed -i "s/@KAFKA_TOPIC@/$KAFKA_TOPIC/" $CB_CONNECT_CFG
sed -i "s/@CONNECTOR_NAME@/$CONNECTOR_NAME/" $CB_CONNECT_CFG
sed -i "s/@COUCHBASE_BUCKET@/$COUCHBASE_BUCKET/" $CB_CONNECT_CFG
sed -i "s/@CONVERTER_CLASS@/$CONVERTER_CLASS/" $CB_CONNECT_CFG
sed -i "s/@FILTER_CLASS@/$FILTER_CLASS/" $CB_CONNECT_CFG
sed -i "s/@COUCHBASE_FROM_TO@/$COUCHBASE_FROM_TO/" $CB_CONNECT_CFG

echo "Calling the start.sh of the Kafka Connector"
exec /$KAFKA_HOME/start.sh

