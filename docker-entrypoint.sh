#!/bin/dumb-init /bin/sh
set -e

if consul_stockpile help "$1" 2>&1 | grep -q "consul_stockpile $1"; then
  set -- consul_stockpile "$@"
fi

if [ "$1" = 'consul_stockpile' ]; then
  # Enable this to run as an unprivileged user
  set -- gosu stockpile "$@"

  if [ -n "$FOG_LOCAL" ]; then
    chown -R stockpile:stockpile /fog
  fi
fi

exec "$@"
