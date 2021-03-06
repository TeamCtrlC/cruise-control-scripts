#!/bin/bash

KAFKA_HOSTS='kafka-0:9092,kafka-1:9092,kafka-2:9092,kafka-3:9092,kafka-4:9092'
ZK_ENSEMBLE='zookeeper:2181'

sed -i "/bootstrap.servers=/ s/=.*/=$KAFKA_HOSTS/" /cruisecontrol.properties
sed -i "/zookeeper.connect=/ s/=.*/=$ZK_ENSEMBLE/" /cruisecontrol.properties

pushd /home/$SERVICE_USER/kafka-current/bin

# Initialize Cruise Control metric topic
# --zookeeper - zookeeper DNS
# --replication-factor - replication factor of the kafka topic
# --partitions - partitions of the kafka topic
# --topic - name of the kafka topic
./kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 3 --topic __CruiseControlMetrics

# Insert more topic here if needed

while [[ "$(./kafka-topics.sh --list --zookeeper zookeeper:2181)" != *"__CruiseControlMetrics"* ]]; do
  echo "Waiting for Metrics topic to be created..."
  sleep 3
done

popd

pushd /home/$SERVICE_USER/cruise-control

# Start cruise-control; arg1 - property file arg2 - cruisecontrol port
./kafka-cruise-control-start.sh /cruisecontrol.properties 8090

popd
