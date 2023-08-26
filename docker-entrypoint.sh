#!/bin/sh
set -e

THIS=$(dirname "$(readlink -f "$0")")
SQITCH_TARGET=''

if [ "$ENV" = "production" ]; then
    SQITCH_TARGET="$(cat /run/secrets/sqitch_target)"
else
    SQITCH_TARGET="$(cat "$THIS/SQITCH_TARGET.env")"
fi

export SQITCH_TARGET

exec /bin/sh -c "$*"
