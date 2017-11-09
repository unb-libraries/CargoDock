#!/usr/bin/env bash
set -e

docker exec -i -t ${SERVICE_NAME} find /app/tests/behat
docker exec -i -t ${SERVICE_NAME} /scripts/runTests.sh
