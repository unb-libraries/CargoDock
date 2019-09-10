#!/usr/bin/env bash
#
# Check the pod startup logs for error strings.
# This does not avoid deploying broken pods, but catches errors when they are deployed.
# Note : At this point we can assume the rollout from previous was successful, so all pods returned are current.
set -e

echo "BRANCH $BRANCH"
echo "IMAGE_TAG $IMAGE_TAG"

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
POD_NAMES=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l instance=$SERVICE_NAME --no-headers | grep 'Running' | tac | awk '{ print $1 }')
POD_COUNTER=0

# Loop over all this deployment's pods.
while IFS_PODS= read -r POD_NAME
do
  POD_COUNTER=$((POD_COUNTER+1))
  printf "\n\n"
  echo "************************************"
  echo "Logs for pod #$POD_COUNTER: $POD_NAME"
  echo "************************************"

  POD_LOGS=$(kubectl logs $POD_NAME --namespace=$BRANCH)
  echo "$POD_LOGS"

  # If error strings found in startup, exit.
  LOWER_POD_LOGS=${POD_LOGS,,}

  ERRORS=''
  ERROR_COUNTER=1

  IGNORED_ERRORS=''
  IGNORED_ERROR_COUNTER=1

  while IFS= read -r line
  do
    if [[ $line == *"error"* ]]; then
      case $line in
           *"access denied for user 'root'"*)
               IGNORED_ERRORS="$IGNORED_ERRORS[#$IGNORED_ERROR_COUNTER] $line\n"
               IGNORED_ERRORS="$IGNORED_ERRORS[#$IGNORED_ERROR_COUNTER] REASON: Initial MySQL status query is expected to fail.\n"
               IGNORED_ERROR_COUNTER=$((IGNORED_ERROR_COUNTER+1));;
           *"config_importer is already importing"*)
               IGNORED_ERRORS="$IGNORED_ERRORS[#$IGNORED_ERROR_COUNTER] $line\n"
               IGNORED_ERRORS="$IGNORED_ERRORS[#$IGNORED_ERROR_COUNTER] REASON: With multiple pods, warnings about config import lock misses should not be considered failures.\n"
               IGNORED_ERROR_COUNTER=$((IGNORED_ERROR_COUNTER+1));;
           *)
               ERRORS="$ERRORS[#$ERROR_COUNTER] $line\n"
               ERROR_COUNTER=$((ERROR_COUNTER+1));;
      esac
    fi
  done < <(printf '%s\n' "$LOWER_POD_LOGS")

  if [[ $ERROR_COUNTER != "1" ]]; then
    printf "\n"
    echo "---------------------------------"
    echo "Errors detected in container startup:"
    echo "---------------------------------"
    printf "$ERRORS\n"
    echo "Reporting Failure."
    exit 1
  fi

  if [[ $IGNORED_ERROR_COUNTER != "1" ]]; then
    printf "\n"
    echo "---------------------------------"
    echo "Errors ignored in container startup:"
    echo "---------------------------------"
    printf "$IGNORED_ERRORS\n"
  fi

    echo "No errors detected in $POD_NAME."

done < <(printf '%s\n' "$POD_NAMES")
