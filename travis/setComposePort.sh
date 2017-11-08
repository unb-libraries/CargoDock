#!/usr/bin/env bash
#
# Update docker-compose.yml port mapping for a service to use local :80.
set -e

sed -i "s|.*:$SERVICE_DEPLOY_PORT\"|      - \"$SERVICE_DEPLOY_PORT:$SERVICE_DEPLOY_PORT\"|g" docker-compose.yml
cat docker-compose.yml
