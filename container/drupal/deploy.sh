#!/usr/bin/env sh
curl -OL http://github.com/unb-libraries/CargoDock/archive/master.zip
unzip master.zip
rsync -a CargoDock-master/container/drupal/ /scripts/
rm -rf master.zip CargoDock-master
