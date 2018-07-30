FROM 1ambda/kafka-connect:latest
COPY target/kafka-connect-couchbase-3.3.2.jar $KAFKA_HOME/connectors
COPY docker .

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["./start-connect.sh"]
CMD [init.sh"]