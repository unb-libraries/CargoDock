#!/usr/bin/env bash
#
# Build the docker images from the lean instance repository and push the built
# images to the registry.
set -e

if [[ $DEPLOY_BRANCHES =~ (^|,)"$TRAVIS_BRANCH"(,|$) ]]; then
  AMAZON_ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
  SERVICE_NAME_SLUG=${SERVICE_NAME//./}
  CACHE_IMAGE="${SERVICE_NAME_SLUG}_${SERVICE_NAME}"

  # Set tagStatus
  BUILD_DATE=$(date '+%Y%m%d%H%M')
  IMAGE_TAG="$TRAVIS_BRANCH-$BUILD_DATE"

  # Write image tag to disk to persist into other steps.
  echo "$IMAGE_TAG" > /tmp/image_tag.txt

  # Build the image and push it to the EC2 registry.
  echo "Building Image For $IMAGE_TAG..."
  docker build --cache-from ${SERVICE_NAME}:latest -t ${SERVICE_NAME}:${IMAGE_TAG} -t ${SERVICE_NAME}:${TRAVIS_BRANCH} .

  echo "Applying Tag and Pushing $IMAGE_TAG to ECR..."
  docker tag ${SERVICE_NAME}:${IMAGE_TAG} ${AMAZON_ECR_URI}/${SERVICE_NAME}:${IMAGE_TAG}
  docker push ${AMAZON_ECR_URI}/${SERVICE_NAME}:${IMAGE_TAG}

  echo "Applying Tag and Pushing $TRAVIS_BRANCH to ECR..."
  docker tag ${SERVICE_NAME}:${TRAVIS_BRANCH} ${AMAZON_ECR_URI}/${SERVICE_NAME}:${TRAVIS_BRANCH}
  docker push ${AMAZON_ECR_URI}/${SERVICE_NAME}:${TRAVIS_BRANCH}
else
  echo "Branch [$TRAVIS_BRANCH] not deployed. Deployable branches : $DEPLOY_BRANCHES"
fi
