#!/usr/bin/env bash
#
# Sleep for a time equal to minReadySeconds of a Kubernetes deployment.
set -e

echo "BRANCH $BRANCH"
echo "IMAGE_TAG $IMAGE_TAG"

# Determine time to pause.
KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
SERVICE_MINREADY_SECONDS=$(kubectl get deployment $KUBE_DEPLOYMENT_NAME -o json --namespace=dev | grep minReadySeconds | awk {'print $2'} | sed 's|,||g')

# Provide default value for sleep if not set.
if [ "$SERVICE_MINREADY_SECONDS" -eq "$SERVICE_MINREADY_SECONDS" ] 2> /dev/null
then
    SLEEP_SECONDS="$SERVICE_MINREADY_SECONDS"
else
    SLEEP_SECONDS='30'
fi

# Sleep.
echo "Sleeping for ${SLEEP_SECONDS}s to allow pod to come up..."
sleep $SLEEP_SECONDS
