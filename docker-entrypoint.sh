#!/bin/sh
set -e

SQITCH_TARGET="$(cat /run/secrets/sqitch_target)"
export SQITCH_TARGET

exec /bin/sh -c "$*"
