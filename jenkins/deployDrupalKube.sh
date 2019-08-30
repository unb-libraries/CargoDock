#!/usr/bin/env bash
#
# Standard k8s deploy Drupal 8 sequence at UNBLibraries.
set -e
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/drupal-8.x-1.x/jenkins/updateKubeDeploymentImage.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/drupal-8.x-1.x/jenkins/pauseForDeploymentCompletion.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/drupal-8.x-1.x/jenkins/waitUntilContainerRunning.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/drupal-8.x-1.x/jenkins/checkForFinishedMarker.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/drupal-8.x-1.x/jenkins/checkDeploymentStartupForError.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/drupal-8.x-1.x/jenkins/restartRsyslogd.sh | bash
