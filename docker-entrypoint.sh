#!/bin/dumb-init /bin/sh
set -e

if [ -n "$USE_BUNDLE_EXEC" ]; then
  STOCKPILE_BINARY="bundle exec consul_stockpile"
else
  STOCKPILE_BINARY=consul_stockpile
fi

if ${STOCKPILE_BINARY} help "$1" 2>&1 | grep -q "consul_stockpile $1"; then
  set -- ${STOCKPILE_BINARY} "$@"
fi

if [ "$1" = "${STOCKPILE_BINARY}" ]; then
  # Enable this to run as an unprivileged user
  set -- gosu stockpile "$@"

  if [ -n "$FOG_LOCAL" ]; then
    chown -R stockpile:stockpile /fog
  fi
fi

exec "$@"
