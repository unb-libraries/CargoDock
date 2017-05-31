#!/usr/bin/env bash

# Build and deploy Drupal docker containers to CoreOS endpoints using Fleet
# and Amazon Simple Container Registry as a storage medium.
#
# There are three primary functions that could  be broken out someday into
# standalone scripts at a future date:
#
#   Triage - Determine branch to build.
#   Build - Build the container
#   Deploy - Deploy to endpoint, optionally making modifications for non-prod.

## Triage.

if [ -z "$BRANCH_NAME" ]; then
  if [ -z "$BRANCH" ]; then
    echo "Branch not set in Github ping or build parameter"
    exit 1
  else
    BUILD_BRANCH="$BRANCH"
  fi
else
  BUILD_BRANCH="$BRANCH_NAME"
fi

BUILD_BRANCH=$(echo $BUILD_BRANCH | sed 's|origin/||g')
echo "$BUILD_BRANCH|$BRANCH_NAME|$BRANCH"

# Get the target host.
DEPLOY_HOST_VAR="DEPLOY_HOST_$BUILD_BRANCH"
if [ -z ${!DEPLOY_HOST_VAR+x} ]; then
  echo "Deploy host unset in ${DEPLOY_HOST_VAR}! Exiting."
  exit 1;
fi
DEPLOY_HOST=${!DEPLOY_HOST_VAR}

## Build.

# Check out the correct branch and get latest changes.
git checkout $BUILD_BRANCH
git pull origin $BUILD_BRANCH
git reset --hard HEAD
git clean -f

# Pull the latest version of the upstream image.
docker pull ${DOCKER_UPSTREAM_IMAGE}

# Build the image and push it to the registry.
$(docker run -i -v $HOME/.aws:/home/aws/.aws unblibraries/aws-cli aws ecr get-login)
docker build -t ${SERVICE_NAME}:${BUILD_BRANCH} .
docker tag ${SERVICE_NAME}:${BUILD_BRANCH} ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${SERVICE_NAME}:${BUILD_BRANCH}
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${SERVICE_NAME}:${BUILD_BRANCH}

## Deploy.

# Get current fleet-unit files.
rm -rf fleet-units
git clone -b ${FLEET_UNIT_REPO_BRANCH} ${FLEET_UNIT_REPO_URI} fleet-units

# Branch based transforms for non-prod servers
if [ "$BUILD_BRANCH" -eq "dev" ]; then
  # MySQL
  sed -i "s|MYSQL_HOSTNAME=mysql.lib.unb.ca|MYSQL_HOSTNAME=mysqldev.lib.unb.ca|g" fleet-units/${SERVICE_NAME}.service
  sed -i '|^    --log-|d' fleet-units/${SERVICE_NAME}.service
  sed -i '|^    -e LOGZIO_KEY|d' fleet-units/${SERVICE_NAME}.service
fi

# Send the appropriate fleet unit up to the server.
scp fleet-units/${SERVICE_NAME}.service ${DEPLOY_HOST}:/tmp/${SERVICE_NAME}.service
rm -rf fleet-units

# Using the fleet unit files, instruct the cluster to reload the new service.
FLEETCTL_COMMAND="ssh $DEPLOY_HOST fleetctl"
${FLEETCTL_COMMAND} list-units

# Destroy the service.
${FLEETCTL_COMMAND} destroy ${SERVICE_NAME}.service || true
sleep 15

# Submit and start the service.
${FLEETCTL_COMMAND} submit /tmp/${SERVICE_NAME}.service
sleep 15
${FLEETCTL_COMMAND} start ${SERVICE_NAME}.service
