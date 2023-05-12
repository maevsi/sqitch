#!/bin/sh

THIS=$(dirname "$(readlink -f "$0")")
image=maevsi/sqitch

docker build -t "$image:build" --target build "$THIS" # --progress plain

container_id="$(docker create $image:build)"
docker cp "$container_id:/srv/app/schema.sql" "$THIS/schema.definition.sql"
docker rm -v "$container_id"
