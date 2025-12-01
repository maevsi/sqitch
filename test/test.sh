#!/bin/sh
set -e

THIS=$(dirname "$(readlink -f "$0")")
IMAGE="maevsi/sqitch"
PLAN_FILE="$THIS/../src/sqitch.plan"
MIGRATION_LINE="data_test 1970-01-01T00:00:00Z Jonas Thelemann <e-mail@jonas-thelemann.de> # Add test data."

add_data_test() {
  cp "$THIS/data/deploy.sql" "$THIS/../src/deploy/data_test.sql"
  cp "$THIS/data/revert.sql" "$THIS/../src/revert/data_test.sql"
  cp "$THIS/data/verify.sql" "$THIS/../src/verify/data_test.sql"

  if [ "$(tail -n 1 "$PLAN_FILE")" != "$MIGRATION_LINE" ]; then
    echo "$MIGRATION_LINE" >> "$PLAN_FILE"
  fi
}

remove_data_test() {
  rm -f "$THIS/../src/deploy/data_test.sql"
  rm -f "$THIS/../src/revert/data_test.sql"
  rm -f "$THIS/../src/verify/data_test.sql"

  sed -i "/$MIGRATION_LINE/d" "$PLAN_FILE"
}

update_schemas() {
  sudo docker build -t "$IMAGE:build" --target test-build "$THIS/.." # --no-cache --progress plain

  CONTAINER_ID=$(sudo docker create "$IMAGE:build")
  sudo docker cp "$CONTAINER_ID:/srv/app/schema_other.sql" "$THIS/fixture/schema_other.definition.sql"
  sudo docker cp "$CONTAINER_ID:/srv/app/schema_vibetype.sql" "$THIS/fixture/schema_vibetype.definition.sql"
  sudo docker rm -v "$CONTAINER_ID"
}

build_test_image() {
  sudo docker build -t "$IMAGE:test" --target test "$THIS/.." # --no-cache --progress plain
}

case "$1" in
  data)
    case "$2" in
      add)
        add_data_test
        ;;
      remove)
        remove_data_test
        ;;
      *)
        echo "Usage: $0 data {add|remove}"
        exit 1
        ;;
    esac
    ;;
  --update)
    update_schemas
    ;;
  *)
    build_test_image
    ;;
esac
