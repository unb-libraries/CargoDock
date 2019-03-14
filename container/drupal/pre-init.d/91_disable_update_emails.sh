#!/usr/bin/env sh
# Squash update emails.
DRUSH_COMMAND="drush --root=${DRUPAL_ROOT} --uri=default --yes"
$DRUSH_COMMAND config-set update.settings notification.emails.0 ''
