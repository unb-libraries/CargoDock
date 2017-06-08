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
#
# Required ENV Variables:
#
#   AWS_ACCOUNT_ID
#   DOCKER_UPSTREAM_IMAGE
#   SERVICE_NAME
#

AMAZON_ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
KUBE_DEPLOYMENT_NAME=${SERVICE_NAME//./-}

## Triage.
##
if [ -z "${BRANCH_NAME}" ]; then
  if [ -z "${BRANCH}" ]; then
    echo "Branch not set in Github ping or build parameter"
    exit 1
  else
    BUILD_BRANCH="${BRANCH}"
  fi
else
  BUILD_BRANCH="${BRANCH_NAME}"
fi

BUILD_BRANCH=$(echo ${BUILD_BRANCH} | sed 's|origin/||g')
echo "Building Branch ${BUILD_BRANCH}"

## Build.
##
# Check out the correct branch and get latest changes.
git checkout ${BUILD_BRANCH}
git pull origin ${BUILD_BRANCH}
git reset --hard HEAD
git clean -f

# Pull the latest version of the upstream image.
docker pull ${DOCKER_UPSTREAM_IMAGE}

# Build the theme(s).
composer install
vendor/bin/dockworker container:theme:build-all

# Build the image and push it to the EC2 registry.
$(docker run -i -v ${HOME}/.aws:/home/aws/.aws unblibraries/aws-cli aws ecr get-login)
docker build -t ${SERVICE_NAME}:${BUILD_BRANCH} .
docker tag ${SERVICE_NAME}:${BUILD_BRANCH} ${AMAZON_ECR_URI}/${SERVICE_NAME}:${BUILD_BRANCH}
IMAGE_SHA256_HASH=$(docker images --no-trunc ${AMAZON_ECR_URI}/${SERVICE_NAME}:${BUILD_BRANCH} --format "{{.ID}}")
docker push ${AMAZON_ECR_URI}/${SERVICE_NAME}:${BUILD_BRANCH}

## Deploy.
##
# Update image hash to latest build.
kubectl get deployment ${KUBE_DEPLOYMENT_NAME} --namespace=${BUILD_BRANCH} -o=yaml | sed "s|\(^\s*\)image: .*|\1image: $AMAZON_ECR_URI/$SERVICE_NAME@$IMAGE_SHA256_HASH|g" > /tmp/${KUBE_DEPLOYMENT_NAME}-new.yml

# Apply updated deployment.
kubectl apply -f /tmp/${KUBE_DEPLOYMENT_NAME}-new.yml --record --namespace=${BUILD_BRANCH}

# Remove temporary job file.
rm -f /tmp/${KUBE_DEPLOYMENT_NAME}-new.yml
