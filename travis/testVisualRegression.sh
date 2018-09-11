#!/usr/bin/env bash
#
# Build the instance theme (if it exists) using dockworker.
set -e

if [[ $DEPLOY_BRANCHES =~ (^|,)"$TRAVIS_BRANCH"(,|$) ]]; then
  if [ -e composer.json ] && [ -e tests/backstop/backstop.json ]; then
    # Remove any remnants of previous composer installs.
    rm -rf vendor
    rm -rf composer.lock

    # Install dependencies.
    composer install --no-suggest --prefer-dist --no-interaction
    if [ -e vendor/bin/dockworker ]; then
      # Build the theme(s).
      echo "Testing visual regression with backstop."
      vendor/bin/dockworker visualreg:test
    fi
  fi
else
  echo "Visual regression testing skipped - [$TRAVIS_BRANCH] not deployed. Deployable branches : $DEPLOY_BRANCHES"
fi
