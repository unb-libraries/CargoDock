#!/usr/bin/env sh
if [[ -n "$LOCAL_HOSTNAME" ]] && [[ -n "$LOCAL_PORT" ]]; then
  printf "\nVisit your instance at:"
  printf "http://$LOCAL_HOSTNAME"

  printf "\nLog-in to your instance via:"
  /scripts/drupalUli.sh
  if nslookup mailhog &> /dev/null; then
    MAILHOG_PORT=$((LOCAL_PORT+1000))
    printf "\nView sent mail at:"
    printf "http://$LOCAL_HOSTNAME:$MAILHOG_PORT"
  fi
fi
