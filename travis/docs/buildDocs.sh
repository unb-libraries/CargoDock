#!/usr/bin/env bash
if [[ $DEPLOY_BRANCHES =~ (^|,)"$TRAVIS_BRANCH"(,|$) ]] && [[ "$DOCKER_BUILD_DOCS" != "FALSE" ]]; then
  cd CargoDock/travis/docs

  # Replace tokenized files
  sed -i "s|SERVICE_NAME|$SERVICE_NAME|g" ./doxygen/config.doxy

  # Copy files from built container.
  docker cp "${SERVICE_NAME}:/app/html" ./tree

  # Remove Composer Deps
  rm -rf ./tree/vendor ./tree/core/assets/vendor

  # Build Docs into ./docs
  docker-compose build --no-cache

  echo "Building docs..."
  docker-compose run doxygen-build

  # Build doxygen docs into tree.
  echo "Building Docs nginx container..."
  cd nginx
  DOCKER_HUB_IMAGE="unb-libraries/${SERVICE_NAME}_docs:latest"
  docker build -t ${DOCKER_HUB_IMAGE} .

  echo "Pushing to dockerhub [$DOCKER_HUB_IMAGE]..."
  docker login -u ${DOCKER_HUB_USERNAME} -p ${DOCKER_HUB_PASSWORD}
  docker push ${DOCKER_HUB_IMAGE}
else
  echo "Docs not built for [$TRAVIS_BRANCH]. Deployable branches : $DEPLOY_BRANCHES"
fi
