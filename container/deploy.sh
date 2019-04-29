#!/usr/bin/env sh
curl -OL http://github.com/unb-libraries/CargoDock/archive/drupal-8.x-1.x.zip
unzip drupal-8.x-1.x.zip
rsync -a ${RSYNC_FLAGS} CargoDock-drupal-8.x-1.x/container/ /scripts/
rm -rf drupal-8.x-1.x.zip CargoDock-drupal-8.x-1.x
