#!/usr/bin/env bash
# Install docker compose on travis instance.
DOCKER_COMPOSE_VERSION='1.16.1'

set -e
curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
sudo mv docker-compose /usr/local/bin
