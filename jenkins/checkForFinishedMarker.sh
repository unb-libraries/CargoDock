#!/usr/bin/env bash
#
# Wait until kube deployment logs show the finished marker.
# @TODO: This should really inspect pod readiness.
MAX_FINISHED_RETRIES=10
FINISHED_RETRY_INTERVAL=15

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
POD_NAMES=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l instance=$SERVICE_NAME --no-headers | grep 'Running' | tac | awk '{ print $1 }')
POD_COUNTER=0

# Loop over all this deployment's pods.
while IFS_PODS= read -r POD_NAME
do
  echo "Checking for pod finished marker in $POD_NAME..."
  FINISHED_RETRY_COUNT=0
  until [ ${FINISHED_RETRY_COUNT} -ge ${MAX_FINISHED_RETRIES} ]; do
    POD_LOGS=$(kubectl logs $POD_NAME --namespace=$BRANCH)
    LOWER_POD_LOGS=${POD_LOGS,,}
    POD_STATUS=$(kubectl describe pod $POD_NAME --namespace=$BRANCH | grep 'Status:' | awk '{ print $2 }')
    if [[ $LOWER_POD_LOGS == *"$DEPLOYMENT_FINISHED_MARKER"* ]]; then
      echo "Finished Marker Found..."
      break 2
    else
      FINISHED_RETRY_COUNT=$[${FINISHED_RETRY_COUNT}+1]
      echo "${POD_NAME} pod is in state ${POD_STATUS}. Waiting [${FINISHED_RETRY_COUNT}/${MAX_FINISHED_RETRIES}] in ${FINISHED_RETRY_INTERVAL}(s) "
      sleep ${FINISHED_RETRY_INTERVAL}
    fi
  done

  if [ ${FINISHED_RETRY_COUNT} -ge ${MAX_FINISHED_RETRIES} ]; then
    echo "${POD_NAME} pod did not log the finished marker ${DEPLOYMENT_FINISHED_MARKER} after ${MAX_FINISHED_RETRIES} attempts!"
    echo "${POD_LOGS}"
    exit 1
  fi
done < <(printf '%s\n' "$POD_NAMES")
