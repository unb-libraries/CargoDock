#!/usr/bin/env bash
set -e

if [ -f ./tests/backstop/$BRANCH/backstop.json ]; then
  echo "Running Regression Tests in /tests/backstop/$BRANCH/..."

  echo "Pulling Upstream Image"
  docker pull docksal/backstopjs

  echo "Running Tests"

  KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
  POD_NAME=$(kubectl get pods --namespace=$BRANCH -l tier=$KUBE_DEPLOYMENT_NAME | grep Running | awk '{ print $1 }' | head -n 1)
  DEV_IP=$(kubectl exec $POD_NAME --namespace=$BRANCH curl ipinfo.io/ip)
  docker run --rm --add-host dev-$SERVICE_NAME:$DEV_IP -v $(pwd)/tests/backstop/$BRANCH:/src docksal/backstopjs test

  TEST_RETURN_CODE=$?
  if [ $TEST_RETURN_CODE != 0 ]; then
    echo "Visual Regression Tests Report Failures. Exiting."
    exit 1
  fi

  echo "Visual Regression Tests Passed."
else
  echo "No Visual Regression Tests in /tests/backstop."
fi
