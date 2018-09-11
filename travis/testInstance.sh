#!/usr/bin/env bash
set -e

# Run container tests.
docker exec -i -t ${SERVICE_NAME} /scripts/runTests.sh

# Test visual regression
CargoDock/travis/testVisualRegression.sh
