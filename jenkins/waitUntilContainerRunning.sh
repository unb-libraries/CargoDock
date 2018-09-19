#!/usr/bin/env bash
#
# Wait until Kubernetes reports the service pod as running.
MAX_CONNECT_RETRIES=5
CONNECT_RETRY_INTERVAL=15

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')

CONNECT_RETRY_COUNT=0
POD_NAME=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l uri=$SERVICE_NAME --no-headers | tac | awk '{ print $1 }' | head -n 1)

echo "Checking if pod $POD_NAME is running..."
until [ ${CONNECT_RETRY_COUNT} -ge ${MAX_CONNECT_RETRIES} ]; do
  POD_STATUS=$(kubectl describe pod $POD_NAME --namespace=$BRANCH | grep 'Status:' | awk '{ print $2 }')
  if [[ "$POD_STATUS" == "Running" ]]; then
    echo "Pod Running..."
    break
  else
    CONNECT_RETRY_COUNT=$[${CONNECT_RETRY_COUNT}+1]
    echo "${POD_NAME} pod is in state ${POD_STATUS}. Waiting [${CONNECT_RETRY_COUNT}/${MAX_CONNECT_RETRIES}] in ${CONNECT_RETRY_INTERVAL}(s) "
    sleep ${CONNECT_RETRY_INTERVAL}
  fi
done

if [ ${CONNECT_RETRY_COUNT} -ge ${MAX_CONNECT_RETRIES} ]; then
  echo "${POD_NAME} pod did not reach running status after ${MAX_CONNECT_RETRIES} attempts!"
  exit 1
fi
