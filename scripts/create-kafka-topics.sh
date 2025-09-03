#!/bin/bash
# ------------------------------------------
# Create Kafka topics for SwiftTrack
# ------------------------------------------

# Kafka bootstrap server (matches docker-compose)
KAFKA_BOOTSTRAP="localhost:9092"

echo "Creating Kafka topics..."

# List of topics
TOPICS=("orders.created" "orders.route_optimized" "orders.wms_updated" "notifications.driver")

for TOPIC in "${TOPICS[@]}"
do
  echo "Creating topic: $TOPIC"
  docker exec -i swift_redpanda rpk topic create $TOPIC --brokers $KAFKA_BOOTSTRAP || true
done

echo "✅ Kafka topics created."
