#!/usr/bin/env sh
# Clear composer cache
if [ "$COMPOSER_CLEAR_CACHE" != "FALSE" ]; then
  rm -rf /root/.composer/cache
fi
