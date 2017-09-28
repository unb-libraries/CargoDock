#!/usr/bin/env bash

# Rollback a Kubernetes deployment to the previous one.
#
# Required ENV Variables:
#
#  SERVICE_NAME
#  BRANCH
#  REVISION_ID (optional)
#
set -e
SCRIPT_DIR=$(dirname $0)

## Triage.
##
KUBE_DEPLOYMENT_NAME=${SERVICE_NAME//./-}
BUILD_BRANCH="$BRANCH"

BUILD_BRANCHES=(dev prod systems)

if [[ ! ${BUILD_BRANCHES[*]} =~ "$BUILD_BRANCH" ]]; then
    echo "Not building branch $BUILD_BRANCH"
    exit 0
fi

echo "Rolling Back ${SERVICE_NAME} | ${BUILD_BRANCH} $1"

if [ -z "$REVISION_ID" ]; then
    kubectl rollout undo deployment/${KUBE_DEPLOYMENT_NAME} --namespace=${BUILD_BRANCH}
else
    kubectl rollout undo deployment/${KUBE_DEPLOYMENT_NAME} --to-revision ${REVISION_ID} --namespace=${BUILD_BRANCH}
fi
