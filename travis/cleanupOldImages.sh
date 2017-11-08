#!/usr/bin/env bash
#
# Remove historical images from AWS ECR if there are more than
# $OLD_IMAGES_TO_KEEP historical images that exist in the repository.
set -e
SCRIPT_DIR=$(dirname $0)

if [[ $DEPLOY_BRANCHES =~ (^|,)"$TRAVIS_BRANCH"(,|$) ]]; then
  AMAZON_ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.$AMAZON_ECR_REGION.amazonaws.com"

  # Set tagStatus
  BUILD_DATE=$(date '+%Y%m%d%H%M')
  IMAGE_TAG="$TRAVIS_BRANCH-$BUILD_DATE"

  # List non-current images
  echo "Cleaning Up Old Images in ECR"
  IMAGE_JSON=$(aws ecr list-images --repository-name=$SERVICE_NAME --region=$AMAZON_ECR_REGION)
  IMAGES_TO_DEL=$(echo "$IMAGE_JSON" | python "$SCRIPT_DIR/filterOldImages.py" -b $TRAVIS_BRANCH -n $OLD_IMAGES_TO_KEEP)

  # Remove non-current images
  if [ ! -z "${IMAGES_TO_DEL// }" ]; then
    while read -r IMAGE; do
      IMAGE_DATE=$(echo $IMAGE | cut -f1 -d\|)
      IMAGE_HASH=$(echo $IMAGE | cut -f2 -d\|)
      echo "Deleting Image From $IMAGE_DATE - $IMAGE_HASH"
      aws ecr batch-delete-image --repository-name=$SERVICE_NAME --region=$AMAZON_ECR_REGION --image-ids=imageDigest=$IMAGE_HASH
    done <<< "$IMAGES_TO_DEL"
  else
    echo "No images to clean up!"
  fi
else
  echo "Not cleaning up images on branch [$TRAVIS_BRANCH]. Deployable branches : $DEPLOY_BRANCHES"
fi
