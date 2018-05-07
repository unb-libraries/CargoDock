#!/usr/bin/env bash
#
# Install tools required to authenticate to AWS ECR, and then authenticate.
# Reads ECR auth creds from env : AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY.
set -e

if [[ $DEPLOY_BRANCHES =~ (^|,)"$TRAVIS_BRANCH"(,|$) ]]; then
  # https://github.com/aws/aws-cli/issues/1522
  export PYTHONWARNINGS="ignore:Unverified HTTPS request"
  pip install --user awscli
  export PATH=$PATH:$HOME/.local/bin
  eval $(aws ecr get-login --no-include-email --region $AMAZON_ECR_REGION)
fi
