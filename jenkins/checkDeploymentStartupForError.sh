#!/usr/bin/env bash
#
# Check the Kubernetes deployment log for errors.
set -e

echo "BRANCH $BRANCH"
echo "IMAGE_TAG $IMAGE_TAG"

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
POD_NAME=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l instance=$SERVICE_NAME --no-headers | tac | awk '{ print $1 }' | head -n 1)

# Logs.
echo "Pod logs:"
POD_LOGS=$(kubectl logs $POD_NAME --namespace=$BRANCH)
echo "$POD_LOGS"

# If error strings found in startup, exit.
LOWER_POD_LOGS=${POD_LOGS,,}

# Exceptions
LOGS_EXCEPTIONS_REMOVED=$(echo "$LOWER_POD_LOGS" | grep -v 'ERROR 1045')

if [[ $LOGS_EXCEPTIONS_REMOVED == *"error"* ]]; then
  echo "**"
  echo "$LOGS_EXCEPTIONS_REMOVED"
  echo "Error found in container startup."
  exit 1
fi
