#!/usr/bin/env bash
#
# Wait until kube deployment logs show the finished marker.
set -e

KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
POD_NAME=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l uri=$SERVICE_NAME --no-headers | tac | awk '{ print $1 }' | head -n 1)

echo "Restarting rsyslogd in $POD_NAME..."
kubectl exec $POD_NAME --namespace=$BRANCH -- killall -9 rsyslogd
sleep 2
kubectl exec $POD_NAME --namespace=$BRANCH -- /usr/sbin/rsyslogd -f /etc/rsyslog.conf
