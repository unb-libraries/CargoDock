#!/usr/bin/env bash
set -e

# Bring up container.
CargoDock/travis/buildInstanceForTesting.sh
CargoDock/travis/waitForDeploy.sh
CargoDock/travis/checkStartupForErrors.sh

# Run container tests.
docker ps
docker exec -i -t ${SERVICE_NAME} /scripts/runTests.sh

# Test visual regression
CargoDock/travis/testVisualRegression.sh
