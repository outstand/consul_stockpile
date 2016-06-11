#!/bin/dumb-init /bin/sh
set -e

if [ -n "$USE_BUNDLE_EXEC" ]; then
  BINARY="bundle exec consul_stockpile"
else
  BINARY=consul_stockpile
fi

if ${BINARY} help "$1" 2>&1 | grep -q "consul_stockpile $1"; then
  set -- gosu stockpile ${BINARY} "$@"

  if [ -n "$FOG_LOCAL" ]; then
    chown -R stockpile:stockpile /fog
  fi
fi

exec "$@"
