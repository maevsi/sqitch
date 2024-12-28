#!/bin/sh

THIS=$(dirname "$(readlink -f "$0")")
image=maevsi/sqitch

sudo docker build -t "$image:build" --target test-build "$THIS/../.." # --no-cache --progress plain

container_id="$(sudo docker create $image:build)"
sudo docker cp "$container_id:/srv/app/schema.sql" "$THIS/schema.definition.sql"
sudo docker rm -v "$container_id"
