#!/usr/bin/env bash
# Wait until application answers request.
set -euo pipefail

# Test the connection
function testNginxPage() {
  curl -I --fail "http://127.0.0.1:$SERVICE_DEPLOY_PORT$SERVICE_TEST_UP_PATH"
  return $?
}

CONNECT_RETRY_COUNT=0
CONNECT_RETRY_INTERVAL=15
MAX_CONNECT_RETRIES=40

until [ ${CONNECT_RETRY_COUNT} -ge ${MAX_CONNECT_RETRIES} ]
do
  testNginxPage && break
  CONNECT_RETRY_COUNT=$[${CONNECT_RETRY_COUNT}+1]
  echo "${SERVICE_NAME} has not deployed. Waiting [${CONNECT_RETRY_COUNT}/${MAX_CONNECT_RETRIES}] in ${CONNECT_RETRY_INTERVAL}(s) "
  sleep ${CONNECT_RETRY_INTERVAL}
done

if [ ${CONNECT_RETRY_COUNT} -ge ${MAX_CONNECT_RETRIES} ]; then
  # Echo logs for failure.
  docker-compose logs

  # Report failure.
  echo "Connecting to ${SERVICE_NAME} failed after ${MAX_CONNECT_RETRIES} attempts!"
  exit 1
fi
