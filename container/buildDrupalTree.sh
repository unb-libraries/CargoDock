#!/usr/bin/env sh
set -e

# Dev/NoDev
DRUPAL_COMPOSER_DEV="${1:-no-dev}"

# Profile ID
DRUPAL_BASE_PROFILE="${2:-minimal}"

# Build instance.
cp ${TMP_DRUPAL_BUILD_DIR}/composer.json ${DRUPAL_BUILD_TMPROOT}
cd ${DRUPAL_BUILD_TMPROOT}
rm -rf /tmp/drupal_build/webroot/sites/all/settings
BUILD_COMMAND="composer update --no-suggest --prefer-dist --no-interaction --${DRUPAL_COMPOSER_DEV}"
echo "Updating Drupal [${BUILD_COMMAND}]"
${BUILD_COMMAND}

# Remove upstream profile
${DRUPAL_BUILD_TMPROOT}/profiles/defaultd

# Create the profile folder.
mkdir -p "${DRUPAL_BUILD_TMPROOT}/profiles/${DRUPAL_SITE_ID}"

# Copy config from core install profile for current version of Drupal.
rsync -a "${DRUPAL_BUILD_TMPROOT}/core/profiles/${DRUPAL_BASE_PROFILE}/config" "${DRUPAL_BUILD_TMPROOT}/profiles/${DRUPAL_SITE_ID}/"

# Copy additional configs provided by dockworker
ADDITIONAL_CONFIG_DIR="/scripts/data/profiles/${DRUPAL_BASE_PROFILE}/config"
if [[ -d "$ADDITIONAL_CONFIG_DIR" ]]; then
  rsync -a ${ADDITIONAL_CONFIG_DIR}/config ${DRUPAL_BUILD_TMPROOT}/profiles/${DRUPAL_SITE_ID}/
fi

# Move local profile from repo to build root, overwriting.
cd ${DRUPAL_BUILD_TMPROOT}
rsync -a --remove-source-files ${TMP_DRUPAL_BUILD_DIR}/${DRUPAL_SITE_ID} ${DRUPAL_BUILD_TMPROOT}/profiles/

# Move settings files into build location.
rm -rf ${DRUPAL_BUILD_TMPROOT}/sites/all/settings
rsync -a --remove-source-files ${TMP_DRUPAL_BUILD_DIR}/settings ${DRUPAL_BUILD_TMPROOT}/sites/all/
