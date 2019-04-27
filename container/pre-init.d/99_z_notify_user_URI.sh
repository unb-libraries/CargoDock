#!/usr/bin/env sh
if [[ -n "$LOCAL_HOSTNAME" ]] && [[ -n "$LOCAL_PORT" ]]; then
  echo "Visit your instance at:"
  echo "http://$LOCAL_HOSTNAME"
  echo "Log-in to your instance via:"
  /scripts/drupalUli.sh
  if nslookup mailhog &> /dev/null; then
    MAILHOG_PORT=$((LOCAL_PORT+1000))
    echo "View sent mail at:"
    echo "http://$LOCAL_HOSTNAME:$MAILHOG_PORT"
  fi
fi
