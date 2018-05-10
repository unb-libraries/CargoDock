#!/usr/bin/env bash
#
# Standard k8s deploy Drupal 8 sequence at UNBLibraries.
set -e
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/master/jenkins/updateKubeDeploymentImage.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/master/jenkins/pauseForDeploymentCompletion.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/master/jenkins/waitUntilContainerRunning.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/master/jenkins/checkForFinishedMarker.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/master/jenkins/checkDeploymentStartupForError.sh | bash
curl -s https://raw.githubusercontent.com/unb-libraries/CargoDock/master/jenkins/restartRsyslogd.sh | bash

