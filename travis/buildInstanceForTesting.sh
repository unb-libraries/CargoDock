#!/usr/bin/env bash
#
# Build and bring up a local instance of the application using docker-compose.
set -e

if [ "$DOCKER_CACHE_BUILD" != "FALSE" ]; then
  AMAZON_ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
  CACHE_IMAGE_NAME_TAG="${AMAZON_ECR_URI}/${SERVICE_NAME}:${TRAVIS_BRANCH}"
  docker pull ${CACHE_IMAGE_NAME}
  docker build --build-arg COMPOSER_DEPLOY_DEV=dev --cache-from ${CACHE_IMAGE_NAME} -t ${SERVICE_NAME}:latest .
else
  docker build --build-arg COMPOSER_DEPLOY_DEV=dev -t ${SERVICE_NAME}:latest .
fi

docker-compose up -d
