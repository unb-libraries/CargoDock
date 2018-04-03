#!/usr/bin/env bash
#
# Check the docker-compose instance's log for errors. Returns code 1 an errors
# is found. Currently only checks instance for the word 'error'.
STARTUP_LOG=$(docker-compose logs "$SERVICE_NAME")

# Echo the log for travis.
echo "$STARTUP_LOG"

# If error strings found in startup, exit.
LOWER_STARTUP_LOG=${STARTUP_LOG,,}
if [[ $LOWER_STARTUP_LOG == *"error"* ]]; then
  # Allow the stdout buffer more time to be written to output
  sleep 10

  # Bring down the hammer.
  echo "Error found in container startup."
  exit 1
fi
