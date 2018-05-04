#!/usr/bin/env sh
# Clear composer cache
if [ "$COMPOSER_CLEAR_CACHE" != "FALSE" ]; then
  composer clear-cache
fi
