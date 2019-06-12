#!/usr/bin/env sh
# Import content via Migrate API and content modules to a site.
CONTENT_DEPLOY_DIR='/tmp'
CONTENT_DIR='/app/content'

# Deploy content if this is the first run, AND the content exists, AND we want the content deployed.
if [[ ! -f /tmp/DRUPAL_DB_LIVE && ! -f /tmp/DRUPAL_FILES_LIVE && -d "$CONTENT_DIR" && "$DRUPAL_IMPORT_CONTENT" = "TRUE" ]];
then
  # Copy content to a deploy dir to avoid altering the mounted volume.
  cp -r "${CONTENT_DIR}" "${CONTENT_DEPLOY_DIR}/"

  # Install common prerequisites
  cd ${DRUPAL_ROOT}
  composer require unb-libraries/drupal-content-migrate

  # Loop over content modules and enable them.
  cd "${CONTENT_DEPLOY_DIR}/content"
  for MODULE_DIR in */; do
    if [ "$MODULE_DIR" != "vendor/" ]; then
      MODULE=$(echo ${MODULE_DIR%/})
      cp -r ${CONTENT_DEPLOY_DIR}/content/${MODULE} ${DRUPAL_ROOT}/modules/custom/
      ${DRUSH} en ${MODULE}
      ${DRUSH} pmu ${MODULE}
      rm -rf "${DRUPAL_ROOT}/modules/custom/${MODULE}"
    fi
  done

  # Restore system module state to that of before the import.
  mkdir -p /tmp/content-import
  cp ${DRUPAL_CONFIGURATION_DIR}/core.extension.yml /tmp/content-import/
  ${DRUSH} cim --partial --source=/tmp/content-import/
  rm -rf /tmp/content-import

  # Remove migration modules from disk.
  cd ${DRUPAL_ROOT}
  composer remove unb-libraries/drupal-content-migrate --update-with-dependencies

  # Remove deploy dir.
  rm -rf "${CONTENT_DEPLOY_DIR}/content"
fi
