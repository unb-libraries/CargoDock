#!/usr/bin/env sh
curl -OL http://github.com/unb-libraries/CargoDock/archive/drupal-8.x-1.x.zip
unzip drupal-8.x-1.x.zip
mv CargoDock-drupal-8.x-1.x CargoDock
rm -rf drupal-8.x-1.x.zip
