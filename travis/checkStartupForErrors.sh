#!/usr/bin/env bash
#
# Check the docker-compose instance's log for errors. Returns code 1 an errors
# is found. Currently only checks instance for the word 'error'.
STARTUP_LOG=$(docker-compose logs "$SERVICE_NAME")
LOWER_POD_LOGS=${STARTUP_LOG,,}

ERRORS=''
ERROR_COUNTER=1

IGNORED_ERRORS=''
IGNORED_ERROR_COUNTER=1

while IFS= read -r line
do
  if [[ $line == *"error"* ]]; then
    case $line in
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

echo "No errors detected in $SERVICE_NAME."
