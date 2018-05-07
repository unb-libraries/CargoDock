#!/usr/bin/env bash
#
# Build the instance theme (if it exists) using dockworker.
set -e

if [[ $DEPLOY_BRANCHES =~ (^|,)"$TRAVIS_BRANCH"(,|$) ]]; then
  if [ -e composer.json ]; then
    # Remove any remnants of previous composer installs.
    rm -rf vendor
    rm -rf composer.lock

    # Install dependencies.
    composer install --no-suggest --prefer-dist --no-interaction
    if [ -e vendor/bin/dockworker ]; then
      # Build the theme(s).
      echo "Building theme using dockworker."
      vendor/bin/dockworker application:theme:build-all
    fi
  fi
else
  echo "Theme building skipped - [$TRAVIS_BRANCH] not deployed. Deployable branches : $DEPLOY_BRANCHES"
fi
