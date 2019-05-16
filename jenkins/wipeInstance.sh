#!/usr/bin/env bash
#
# Destroy all persistent data in a deployment and re-install.
if [[ -z "$1" ]]
then
  echo "Service name not set!"
  exit 1
fi

if [[ -z "$2" ]]
then
  echo "Branch name not set!"
  exit 1
fi

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
CONNECT_RETRY_COUNT=0
POD_NAME=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l instance=$SERVICE_NAME --no-headers | tac | awk '{ print $1 }' | head -n 1)
KUBE_EXEC="kubectl exec -it "$POD_NAME" --namespace="$BRANCH" --"
SITE_ID=$($KUBE_EXEC sh -lc "echo \$DRUPAL_SITE_ID")

echo "Wiping all data for $SERVICE_NAME:$BRANCH"
echo "Kubernetes Pod ID: $POD_NAME"

# Drop database
echo "Dropping database..."
$KUBE_EXEC sh -lc "drush --yes --root=/app/html sql-drop"

# Delete Files
echo "Deleting filesystem..."
$KUBE_EXEC sh -lc "rm -rf /app/html/sites/default/*"
$KUBE_EXEC sh -lc "rm -rf /app/html/sites/default/.*"

# Kill Nginx, causing pull and redeploy.
echo "Restarting service..."
$KUBE_EXEC sh -lc "nginx -s stop"
