#!/bin/sh
set -e

THIS=$(dirname "$(readlink -f "$0")")
image=maevsi/sqitch

if [ "$1" = "--update" ]; then
  sudo docker build -t "$image:build" --target test-build "$THIS/.." # --no-cache --progress plain

  container_id="$(sudo docker create $image:build)"
  sudo docker cp "$container_id:/srv/app/schema.sql" "$THIS/fixture/schema.definition.sql"
  sudo docker rm -v "$container_id"
else
  sudo docker build -t "$image:test" --target test "$THIS/.." # --no-cache --progress plain
fi
