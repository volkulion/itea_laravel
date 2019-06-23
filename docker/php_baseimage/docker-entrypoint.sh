#!/bin/bash -
set -e

if [ -z "${1}" ]; then
    supervisord
fi

exec "$@"

