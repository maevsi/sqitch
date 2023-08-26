#!/bin/sh
set -e

SQITCH_TARGET=''

if [ "$NODE_ENV" = "production" ]; then
    SQITCH_TARGET="$(cat /run/secrets/sqitch_target)"
else
    SQITCH_TARGET="$(cat "$PWD/SQITCH_TARGET.env")"
fi
export SQITCH_TARGET

exec /bin/sh -c "$*"
