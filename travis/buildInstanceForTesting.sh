#!/usr/bin/env bash
#
# Build and bring up a local instance of the application using docker-compose.
set -e
echo "Building instance for testing..."

# Caching this step from upstream was causing problems with old CargoDock.
docker build --build-arg -t ${SERVICE_NAME}:latest .

if [[ "$DEBUG_CONTAINER_START" == "TRUE" ]]; then
  echo "Starting container, debug mode activated - Testing WILL FAIL"
  docker-compose up
else
  docker-compose up -d
fi
