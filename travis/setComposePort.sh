#!/usr/bin/env bash
#
# Update docker-compose.yml port mapping for a service to use local :80.
set -e

sed -i 's|.*:80\"|      - "80:80"|g' docker-compose.yml
cat docker-compose.yml
