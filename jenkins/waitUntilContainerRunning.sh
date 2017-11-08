#!/usr/bin/env bash
#
# Wait until Kubernetes reports the service pod as running.
MAX_CONNECT_RETRIES=5
CONNECT_RETRY_COUNT=0
CONNECT_RETRY_INTERVAL=15

echo "Checking if pod is running..."
until [ ${CONNECT_RETRY_COUNT} -ge ${MAX_CONNECT_RETRIES} ]
do
  POD_STATUS=$(kubectl describe pod $KUBE_DEPLOYMENT_NAME --namespace=$BRANCH | grep 'Status:' | awk '{ print $2 }')
  if [ $POD_STATUS = "Running" ]; then
    echo "Pod Running..."
    break
  else
    CONNECT_RETRY_COUNT=$[${CONNECT_RETRY_COUNT}+1]
    echo "${SERVICE_NAME} pod is in state ${POD_STATUS}. Waiting [${CONNECT_RETRY_COUNT}/${MAX_CONNECT_RETRIES}] in ${CONNECT_RETRY_INTERVAL}(s) "
    sleep ${CONNECT_RETRY_INTERVAL}
  fi
done

if [ ${CONNECT_RETRY_COUNT} -ge ${MAX_CONNECT_RETRIES} ]; then
  echo "${SERVICE_NAME} pod did not reach running status after ${MAX_CONNECT_RETRIES} attempts!"
  exit 1
fi
