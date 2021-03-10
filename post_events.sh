#!/usr/bin/env bash

HOSTNAME="http://localhost:3000"

echo "Posting events.json to $HOSTNAME/endpoint"

counter=1

cat events.json | while read line
do
  curl -H "Content-Type: application/json" --data "$line" $HOSTNAME/endpoint
  # You can add a `sleep` in here if its too much data at once
  echo ""
  counter=$((counter+1))
  echo $counter
done
