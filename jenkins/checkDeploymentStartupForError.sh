#!/usr/bin/env bash
#
# Check the Kubernetes deployment log for errors.
set -e

echo "BRANCH $BRANCH"
echo "IMAGE_TAG $IMAGE_TAG"

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
POD_NAME=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l uri=$SERVICE_NAME --no-headers | tac | awk '{ print $1 }' | head -n 1)

# Logs.
echo "Pod logs:"
POD_LOGS=$(kubectl logs $POD_NAME --namespace=$BRANCH)
echo "$POD_LOGS"

# If error strings found in startup, exit.
LOWER_POD_LOGS=${POD_LOGS,,}
if [[ $LOWER_POD_LOGS == *"error"* ]]; then
  echo "Error found in container startup."
  exit 1
fi
