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
set -e

AMAZON_ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
KUBE_DEPLOYMENT_NAME=${SERVICE_NAME//./-}

BUILD_BRANCH="${BRANCH:-$GIT_BRANCH}"
BUILD_BRANCH=$(echo ${BUILD_BRANCH} | sed 's|origin/||g')

BUILD_BRANCHES=(dev prod)

if [[ ! ${BUILD_BRANCHES[*]} =~ "$BUILD_BRANCH" ]]; then
    echo "Not building branch $BUILD_BRANCH"
    exit 0
fi

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
docker build --no-cache -t ${SERVICE_NAME}:${BUILD_BRANCH} .
docker tag ${SERVICE_NAME}:${BUILD_BRANCH} ${AMAZON_ECR_URI}/${SERVICE_NAME}:${BUILD_BRANCH}
docker push ${AMAZON_ECR_URI}/${SERVICE_NAME}:${BUILD_BRANCH}
IMAGE_SHA256_HASH=$(docker pull ${AMAZON_ECR_URI}/${SERVICE_NAME}:${BUILD_BRANCH} | grep 'Digest:' | awk '{ print $2 }')

## Deploy.
##
# Notification.
echo "\n\nSHA of ${AMAZON_ECR_URI}/${SERVICE_NAME}:${BUILD_BRANCH} appears to be ${IMAGE_SHA256_HASH}, deploying.\n\n"

# Update image hash to latest build.
kubectl get deployment ${KUBE_DEPLOYMENT_NAME} --namespace=${BUILD_BRANCH} -o=yaml | sed "s|\(^\s*\)image: .*|\1image: $AMAZON_ECR_URI/$SERVICE_NAME@$IMAGE_SHA256_HASH|g" > /tmp/${KUBE_DEPLOYMENT_NAME}-new.yml

# Apply updated deployment.
kubectl apply -f /tmp/${KUBE_DEPLOYMENT_NAME}-new.yml --record --namespace=${BUILD_BRANCH}

# Remove temporary job file.
rm -f /tmp/${KUBE_DEPLOYMENT_NAME}-new.yml
