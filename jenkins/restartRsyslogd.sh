#!/usr/bin/env bash
#
# Restart rsyslogd to send logs upstream.
set -e

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
POD_NAMES=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l instance=$SERVICE_NAME --no-headers | grep 'Running' | tac | awk '{ print $1 }')
POD_COUNTER=0

# Loop over all this deployment's pods.
while IFS_PODS= read -r POD_NAME
do
  POD_COUNTER=$((POD_COUNTER+1))
  echo "Restarting rsyslogd in $POD_NAME..."
  kubectl exec $POD_NAME --namespace=$BRANCH -- killall -9 rsyslogd
  sleep 2
  kubectl exec $POD_NAME --namespace=$BRANCH -- /usr/sbin/rsyslogd -f /etc/rsyslog.conf
done < <(printf '%s\n' "$POD_NAMES")
