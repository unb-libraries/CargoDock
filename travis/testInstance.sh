#!/usr/bin/env bash
set -e

docker exec -i -t ${SERVICE_NAME} /scripts/runTests.sh
