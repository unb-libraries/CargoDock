#!/usr/bin/env bash
#
# Build and bring up a local instance of the application using docker-compose.
set -e

docker-compose build
docker images
docker-compose up -d
