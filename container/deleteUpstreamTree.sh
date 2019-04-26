#!/usr/bin/env sh
set -e

# Delete files from parent repo build, allowing a local build.
rm -rf ${TMP_DRUPAL_BUILD_DIR}
mkdir -p ${TMP_DRUPAL_BUILD_DIR}

# Remove Drupal console from upstream, installed with site
rm -f /usr/bin/drupal

# Remove upstream tests.
rm -rf ${DRUPAL_TESTING_ROOT}
