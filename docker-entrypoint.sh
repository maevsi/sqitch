#!/bin/sh
set -e

SQITCH_TARGET="$(cat /run/secrets/sqitch-target)"
export SQITCH_TARGET

exec /bin/sh -c "$*"
