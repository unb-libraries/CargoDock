#!/usr/bin/env sh
if [[ -n "$LOCAL_HOSTNAME" ]] && [[ -n "$LOCAL_PORT" ]]; then
  printf "\n\nVisit your instance at:"
  printf "\nhttp://$LOCAL_HOSTNAME"

  printf "\n\nLog-in to your instance via:\n"
  /scripts/drupalUli.sh
  if nslookup mailhog &> /dev/null; then
    MAILHOG_PORT=$((LOCAL_PORT+1000))
    printf "\n\nView sent mail at:"
    printf "\nhttp://$LOCAL_HOSTNAME:$MAILHOG_PORT"
  fi
fi
