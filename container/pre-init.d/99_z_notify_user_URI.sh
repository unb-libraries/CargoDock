#!/usr/bin/env sh
if [[ -n "$LOCAL_HOSTNAME" ]] && [[ -n "$LOCAL_PORT" ]]; then
  echo "\nVisit your instance at:"
  echo "http://$LOCAL_HOSTNAME"

  echo "\nLog-in to your instance via:"
  /scripts/drupalUli.sh
  if nslookup mailhog &> /dev/null; then
    MAILHOG_PORT=$((LOCAL_PORT+1000))
    echo "\nView sent mail at:"
    echo "http://$LOCAL_HOSTNAME:$MAILHOG_PORT"
  fi
fi
