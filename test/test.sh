#!/bin/sh
set -e

THIS=$(dirname "$(readlink -f "$0")")
image=maevsi/sqitch

if [ "$1" = "--data" ]; then
  git apply --3way test/development/data.patch || true

  while git diff --name-only --diff-filter=U | grep . > /dev/null; do
    echo "Merge conflicts detected. Please resolve them and press enter to continue..."

    # shellcheck disable=SC2034
    read -r dummy
  done

  npm run deploy
elif [ "$1" = "--update" ]; then
  sudo docker build -t "$image:build" --target test-build "$THIS/.." # --no-cache --progress plain

  container_id="$(sudo docker create $image:build)"
  sudo docker cp "$container_id:/srv/app/schema_other.sql" "$THIS/fixture/schema_other.definition.sql"
  sudo docker cp "$container_id:/srv/app/schema_vibetype.sql" "$THIS/fixture/schema_vibetype.definition.sql"
  sudo docker rm -v "$container_id"
else
  sudo docker build -t "$image:test" --target test "$THIS/.." # --no-cache --progress plain
fi
