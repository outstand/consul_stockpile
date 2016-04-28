#!/bin/dumb-init /bin/sh
set -e

if consul_stockpile help "$1" 2>&1 | grep -q "consul_stockpile $1"; then
  set -- consul_stockpile "$@"
fi

# Enable this to run as an unprivileged user
if [ "$1" = 'consul_stockpile' ]; then
  set -- gosu stockpile "$@"
fi

exec "$@"
