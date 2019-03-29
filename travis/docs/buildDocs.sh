#!/usr/bin/env bash
if [[ $DEPLOY_BRANCHES =~ (^|,)"$TRAVIS_BRANCH"(,|$) ]] && [[ "$DOCKER_BUILD_DOCS" != "FALSE" ]]; then
  # Copy files from built container.
  docker cp "${SERVICE_NAME}:/app/html" ./CargoDock/travis/docs/tree

  # Remove Composer Deps
  rm -rf ./CargoDock/travis/docs/tree/vendor ./CargoDock/travis/docs/tree/core/assets/vendor

  # Replace tokenized files
  sed -i "s|SERVICE_NAME|$SERVICE_NAME|g" ./CargoDock/travis/docs/doxygen/config.doxy

  # Build Docs into ./docs
  cd ./CargoDock/travis/docs
  docker-compose build --no-cache

  echo "Building docs..."
  docker-compose run doxygen-build

  # Build doxygen docs into tree.
  echo "Building Docs nginx container..."
  cd nginx
  DOCKER_HUB_IMAGE="unb-libraries/${SERVICE_NAME}_docs:latest"
  cp ../docs .
  docker build -t ${DOCKER_HUB_IMAGE} .

  echo "Pushing to dockerhub [$DOCKER_HUB_IMAGE]..."
  docker login -u ${DOCKER_HUB_USERNAME} -p ${DOCKER_HUB_PASSWORD}
  docker push ${DOCKER_HUB_IMAGE}
else
  echo "Docs not built for [$TRAVIS_BRANCH]. Deployable branches : $DEPLOY_BRANCHES"
fi
