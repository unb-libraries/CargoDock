#!/usr/bin/env bash
#
# Build and bring up a local instance of the application using docker-compose.
set -e

docker build --build-arg COMPOSER_DEPLOY_DEV=dev -t ${SERVICE_NAME}:latest .
docker-compose up -d
