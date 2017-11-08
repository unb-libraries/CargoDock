#!/usr/bin/env bash
#
# Update the deploy environment to match the branch.
set -e

sed -i "s|DEPLOY_ENV=local|DEPLOY_ENV=$TRAVIS_BRANCH|g" env/drupal.env
cat env/drupal.env
