#!/usr/bin/env sh

# Dev/NoDev
DRUPAL_COMPOSER_DEV="${1:-no-dev}"

# Dev Addons.
echo "DRUPAL_COMPOSER_DEV = $DRUPAL_COMPOSER_DEV"
if [ "$DRUPAL_COMPOSER_DEV" == "dev" ]; then
  echo "Installing Dev Tools..."

  # Copy default services if no services.yml has been provided
  if [[ ! -f "${DRUPAL_BUILD_TMPROOT}/sites/default/services.yml" ]]; then
    cp "${DRUPAL_BUILD_TMPROOT}/sites/default/default.services.yml" "${DRUPAL_BUILD_TMPROOT}/sites/default/services.yml"
  fi

  # Twig settings
  sed -i "s|debug: false|debug: true|g" ${DRUPAL_BUILD_TMPROOT}/sites/default/services.yml
  sed -i "s|cache: true|cache: false|g" ${DRUPAL_BUILD_TMPROOT}/sites/default/services.yml
fi

# Blackfire/NoBlackfire.
INSTALL_BLACKFIRE_PROBE="${2:-FALSE}"

echo "INSTALL_BLACKFIRE_PROBE = $INSTALL_BLACKFIRE_PROBE"
if [ "$INSTALL_BLACKFIRE_PROBE" == "TRUE" ]; then
  echo "Installing Blackfire Probe..."
  /scripts/installBlackfireProbe.sh

  echo "Installing Blackfire CLI..."
  /scripts/installBlackfireCli.sh
fi
