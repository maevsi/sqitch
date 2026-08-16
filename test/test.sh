#!/bin/sh
set -e

THIS=$(dirname "$(readlink -f "$0")")
IMAGE="maevsi/sqitch"
PLAN_FILE="$THIS/../src/sqitch.plan"
MIGRATION_LINE="data_test 1970-01-01T00:00:00Z Jonas Thelemann <e-mail@jonas-thelemann.de> # Add test data."

if docker info > /dev/null 2>&1; then
  DOCKER="docker"
else
  DOCKER="sudo docker"
fi

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

  # `sed -i` needs a (possibly empty) backup-suffix argument on BSD/macOS sed but rejects one on GNU
  # sed, so neither `-i ''` nor `-i` alone is portable across both. Writing to a temp file and moving
  # it into place works the same everywhere.
  tmp="$(mktemp "${PLAN_FILE}.tmp.XXXXXX")"
  trap 'rm -f "$tmp"' 0
  sed "/$MIGRATION_LINE/d" "$PLAN_FILE" > "$tmp"
  cat "$tmp" > "$PLAN_FILE"
  rm -f "$tmp"; trap - 0
}

deny_if_data_test_present() {
  # A `data add` left over from an earlier interactive session must not leak into an automated run:
  # `test/logic` assumes an exact, minimal row set, and seeded dev data breaks that (see e.g. the
  # `event/location` and `event/policy` scenario tests). Refuse to run rather than silently
  # removing it, since the data_test files may have been hand-edited.
  if [ "$(tail -n 1 "$PLAN_FILE")" = "$MIGRATION_LINE" ]; then
    echo "Test data is present (added via 'pnpm test:data:add'). Since it may have been hand-edited," >&2
    echo "run 'pnpm test:data:remove' (or stash the changes) before running this." >&2
    exit 1
  fi
}

update_schemas() {
  deny_if_data_test_present

  $DOCKER build -t "$IMAGE:build" --target test-build "$THIS/.." # --no-cache --progress plain

  CONTAINER_ID=$($DOCKER create "$IMAGE:build")
  $DOCKER cp "$CONTAINER_ID:/srv/app/schema_other.sql" "$THIS/fixture/schema_other.definition.sql"
  $DOCKER cp "$CONTAINER_ID:/srv/app/schema_vibetype.sql" "$THIS/fixture/schema_vibetype.definition.sql"
  $DOCKER rm -v "$CONTAINER_ID"
}

build_test_image() {
  deny_if_data_test_present

  $DOCKER build -t "$IMAGE:test" --target test "$THIS/.." # --no-cache --progress plain
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
