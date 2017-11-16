#!/usr/bin/env bash
#
# Build and bring up a local instance of the application using docker-compose.
set -e

if [ "$DOCKER_CACHE_BUILD" != "FALSE" ]; then
  AMAZON_ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
  CACHE_IMAGE_NAME_TAG="${AMAZON_ECR_URI}/${SERVICE_NAME}:${TRAVIS_BRANCH}"

  if docker pull ${CACHE_IMAGE_NAME_TAG} ; then
    docker build --build-arg COMPOSER_DEPLOY_DEV=dev --cache-from ${CACHE_IMAGE_NAME_TAG} -t ${SERVICE_NAME}:latest .
  else
    docker build --build-arg COMPOSER_DEPLOY_DEV=dev -t ${SERVICE_NAME}:latest .
  fi

  docker build --build-arg COMPOSER_DEPLOY_DEV=dev --cache-from ${CACHE_IMAGE_NAME_TAG} -t ${SERVICE_NAME}:latest .
else
  docker build --build-arg COMPOSER_DEPLOY_DEV=dev -t ${SERVICE_NAME}:latest .
fi

if [ "$DEBUG_CONTAINER_START" == "TRUE" ]; then
  echo "Starting container, debug mode activated - Testing WILL FAIL"
  docker-compose up
else
  docker-compose up -d
fi
