#!/usr/bin/env sh
set -e

# Dev/NoDev
DRUPAL_COMPOSER_DEV="${1:-no-dev}"

# Build instance.
cp ${TMP_DRUPAL_BUILD_DIR}/composer.json ${DRUPAL_BUILD_TMPROOT}
cd ${DRUPAL_BUILD_TMPROOT}
rm -rf /tmp/drupal_build/webroot/sites/all/settings
BUILD_COMMAND="composer update --no-suggest --prefer-dist --no-interaction --${DRUPAL_COMPOSER_DEV}"
echo "Updating Drupal [${BUILD_COMMAND}]"
${BUILD_COMMAND}

# Move profile from repo to build root.
cd ${DRUPAL_BUILD_TMPROOT}
mv ${TMP_DRUPAL_BUILD_DIR}/${DRUPAL_SITE_ID} ${DRUPAL_BUILD_TMPROOT}/profiles/

# Copy config from standard install profile for current version of Drupal.
cp -r ${DRUPAL_BUILD_TMPROOT}/core/profiles/minimal/config ${DRUPAL_BUILD_TMPROOT}/profiles/${DRUPAL_SITE_ID}/

# Move settings files into build location.
rm -rf ${DRUPAL_BUILD_TMPROOT}/sites/all/settings
mv ${TMP_DRUPAL_BUILD_DIR}/settings ${DRUPAL_BUILD_TMPROOT}/sites/all/
