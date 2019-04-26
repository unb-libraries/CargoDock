#!/usr/bin/env sh
# Remove existing configuration.
rm -rf ${DRUPAL_CONFIGURATION_DIR}/*

# Write out config.
${DRUSH} config-export --destination=${DRUPAL_CONFIGURATION_DIR}
rm -rf ${DRUPAL_CONFIGURATION_DIR}/*devel*
