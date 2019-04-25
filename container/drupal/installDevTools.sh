#!/usr/bin/env sh

# Dev/NoDev
DRUPAL_COMPOSER_DEV="${1:-no-dev}"

# Dev Addons.
if [ "$DRUPAL_COMPOSER_DEV" == "dev" ]; then
  ## Testing Tools
  # Behat.
  cd ${DRUPAL_TESTING_ROOT}/behat
  rm -rf vendor composer.lock
  composer install --no-suggest --no-interaction --prefer-dist

  # Copy default services
  cp ${DRUPAL_BUILD_TMPROOT}/sites/default/default.services.yml ${DRUPAL_BUILD_TMPROOT}/sites/default/services.yml

  # Twig settings
  sed -i "s|debug: false|debug: true|g" ${DRUPAL_BUILD_TMPROOT}/sites/default/services.yml
  sed -i "s|cache: true|cache: false|g" ${DRUPAL_BUILD_TMPROOT}/sites/default/services.yml
fi

# Install Blackfire probe.
INSTALL_BLACKFIRE_PROBE="${1:-FALSE}"
if [[ "$INSTALL_BLACKFIRE_PROBE" == "TRUE" ]]; then
  /scripts/installBlackfire.sh
fi
