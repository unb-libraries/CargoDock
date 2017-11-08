#!/usr/bin/env bash
#
# Trigger Jenkins Kubernetes image update job.
set -e

# Retrieve tag from buildPushToRepo.
IMAGE_TAG=$(cat /tmp/image_tag.txt)

# Get CSRF protection token 'CRUMB'.
CRUMB=$(curl -s "https://$JENKINS_USER_CREDS@$JENKINS_HOSTNAME/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
sleep 2

# Trigger build on Jenkins.
curl -X POST -H "$CRUMB" "https://$JENKINS_USER_CREDS@$JENKINS_HOSTNAME/job/$SERVICE_NAME.$TRAVIS_BRANCH/buildWithParameters?TOKEN_NAME=$JENKINS_TRIGGER_TOKEN&IMAGE_TAG=$IMAGE_TAG&AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID"
