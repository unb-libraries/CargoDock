#!/usr/bin/env bash
#
# Wait until Kubernetes reports the rollout as successful.
MAX_CONNECT_RETRIES=5
CONNECT_RETRY_INTERVAL=15

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')

CONNECT_RETRY_COUNT=0

echo "Checking rollout status of deployment..."
until [ ${CONNECT_RETRY_COUNT} -ge ${MAX_CONNECT_RETRIES} ]; do
  ROLLOUT_STATUS=$(kubectl rollout status deployment $KUBE_DEPLOYMENT_NAME -n $BRANCH)
  if [[ "$ROLLOUT_STATUS" == *"successfully rolled out"* ]]; then
    echo "$ROLLOUT_STATUS"
    break
  else
    CONNECT_RETRY_COUNT=$[${CONNECT_RETRY_COUNT}+1]
    echo "$ROLLOUT_STATUS"
    sleep ${CONNECT_RETRY_INTERVAL}
  fi
done

if [ ${CONNECT_RETRY_COUNT} -ge ${MAX_CONNECT_RETRIES} ]; then
  echo "${KUBE_DEPLOYMENT_NAME} rollout did not reach succesful status after ${MAX_CONNECT_RETRIES} attempts!"
  exit 1
fi
