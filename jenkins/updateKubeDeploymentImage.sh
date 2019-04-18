#!/usr/bin/env bash
#
# Update the deployment image on Kubernetes.
set -e

# Update image on Kubernetes. Trigger from Jenkins job with two arguments:
echo "Updating:"
echo "BRANCH $BRANCH"
echo "IMAGE_TAG $IMAGE_TAG"

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')

# Update image hash to tag.
echo "Updating image for $SERVICE_NAME - $BRANCH to $IMAGE_TAG in Kubernetes..."
UPDATE_COMMAND="kubectl set image --record deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_DEPLOYMENT_NAME}=$AMAZON_ECR_URI/$SERVICE_NAME:$IMAGE_TAG --namespace=${BRANCH}"
echo "$UPDATE_COMMAND"
$UPDATE_COMMAND
