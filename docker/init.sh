#!/bin/sh
#Retrieving container ip address for advertising to other Kafka connect workers
#CONTAINER_IP=`hostname --ip-address`
CONTAINER_IP=$(tail -1 /etc/hosts | awk '{print $1}')

#Setting environment variables for connector > kafka part
sed -i "s/@CONTAINER_IP@/$CONTAINER_IP/" config/connect-distributed.properties
sed -i "s/@KAFKA_ADDRESS@/$KAFKA_ADDRESS/" config/connect-distributed.properties
sed -i "s/@CONNECTOR_TYPE@/$CONNECTOR_TYPE/" config/connect-distributed.properties

#Setting environement variables for connector > couchbase part
sed -i "s/@COUCHBASE_NODES@/$COUCHBASE_NODES/" config/connector-rest-config.json
sed -i "s/@KAFKA_TOPIC@/$KAFKA_TOPIC/" config/connector-rest-config.json
sed -i "s/@CONNECTOR_NAME@/$CONNECTOR_NAME/" config/connector-rest-config.json
sed -i "s/@COUCHBASE_BUCKET@/$COUCHBASE_BUCKET/" config/connector-rest-config.json
sed -i "s/@CONVERTER_CLASS@/$CONVERTER_CLASS/" config/connector-rest-config.json
sed -i "s/@FILTER_CLASS@/$FILTER_CLASS/" config/connector-rest-config.json
sed -i "s/@COUCHBASE_FROM_TO@/$COUCHBASE_FROM_TO/" config/connector-rest-config.json



# Set configurations
# First check, in case of restart of Kafka Connect and connector configuration, connector info is already stored in kafka internal topics
if [[ *${CONNECTOR_NAME}* != $(curl -s -GET localhost:8083/connectors/) ]]; then
    while [[ $(curl -s -GET localhost:8083/connectors/) != "["* ]] #when the connector is up, the curl response yields connectors name between brackets, ex '[]'or '[Connector-1, Connector-2]'
    do
	echo "Waiting connector to be up for configuration"
	sleep 2
    done
    
    #Random sleep to prevent race
    sleep $((3 + $RANDOM % 50))

    #Test if connector already created, otherwise create it
    if [[ *${CONNECTOR_NAME}* != $(curl -s -GET localhost:8083/connectors/) ]]; then
	curl -XPOST http://localhost:8083/connectors -d "@./config/connector-rest-config.json" -H "Content-Type: application/json"
    fi
else
    echo "Connector already exists"
fi
