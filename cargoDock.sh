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
SCRIPT_DIR=$(dirname $0)

ECR_REGION='us-east-1'
AMAZON_ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
KUBE_DEPLOYMENT_NAME=${SERVICE_NAME//./-}

BUILD_BRANCH="${BRANCH:-$GIT_BRANCH}"
BUILD_BRANCH=$(echo ${BUILD_BRANCH} | sed 's|origin/||g')

BUILD_BRANCHES=(dev prod systems)

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

if [ -e composer.json ]; then
  # Remove any remnants of previous composer installs.
  rm -rf vendor
  rm -rf composer.lock

  # Install dependencies.
  composer install
  if [ -e vendor/bin/dockworker ]; then
    # Build the theme(s).
    vendor/bin/dockworker container:theme:build-all
  fi
fi

# Set tagStatus
BUILD_DATE=$(date '+%Y%m%d%H%M')
IMAGE_TAG="$BUILD_BRANCH-$BUILD_DATE"

# Build the image and push it to the EC2 registry.
echo "Building Image Locally..."
$(docker run -i -v ${HOME}/.aws:/home/aws/.aws unblibraries/aws-cli aws ecr get-login)
docker build --no-cache -t ${SERVICE_NAME}:${IMAGE_TAG} .

echo "Applying Tags and Pushing to ECR..."
docker tag ${SERVICE_NAME}:${IMAGE_TAG} ${AMAZON_ECR_URI}/${SERVICE_NAME}:${IMAGE_TAG}
docker push ${AMAZON_ECR_URI}/${SERVICE_NAME}:${IMAGE_TAG}

# Also Tag default build_branch.
docker build -t ${SERVICE_NAME}:${BUILD_BRANCH} .
docker tag ${SERVICE_NAME}:${BUILD_BRANCH} ${AMAZON_ECR_URI}/${SERVICE_NAME}:${BUILD_BRANCH}
docker push ${AMAZON_ECR_URI}/${SERVICE_NAME}:${BUILD_BRANCH}

# Update image hash to latest build.
echo "Updating Image in Kubernetes..."
kubectl set image --record deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_DEPLOYMENT_NAME}=$AMAZON_ECR_URI/$SERVICE_NAME:$IMAGE_TAG --namespace=${BUILD_BRANCH}

# Remove non-current images
echo "Cleaning Up Old Images in ECR"
IMAGE_JSON=$(docker run -i -v ${HOME}/.aws:/home/aws/.aws unblibraries/aws-cli aws ecr list-images --repository-name=$SERVICE_NAME --region=$ECR_REGION)
IMAGES_TO_DEL=$(echo "$IMAGE_JSON" | python $SCRIPT_DIR/getOldImages.py $BUILD_BRANCH)
echo "$IMAGES_TO_DEL"

if [ ! -z "${IMAGES_TO_DEL// }" ]; then
  while read -r IMAGE; do
    IMAGE_DATE=$(echo $IMAGE | cut -f1 -d\|)
    IMAGE_HASH=$(echo $IMAGE | cut -f2 -d\|)
    echo "Deleting Image From $IMAGE_DATE - $IMAGE_HASH"
    docker run -v ${HOME}/.aws:/home/aws/.aws unblibraries/aws-cli aws ecr batch-delete-image --repository-name=$SERVICE_NAME --region=$ECR_REGION --image-ids=imageDigest=$IMAGE_HASH
  done <<< "$IMAGES_TO_DEL"
else
  echo "No images to clean up!"
fi
