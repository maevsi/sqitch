#!/usr/bin/env bash
set -euo pipefail

IMAGE="${SMOKE_TEST_IMAGE:?SMOKE_TEST_IMAGE not set}"
SUFFIX="${GITHUB_RUN_ID:-$$}-${GITHUB_RUN_ATTEMPT:-1}"
CONTAINER_DB="smoke-db-${SUFFIX}"
NETWORK="smoke-${SUFFIX}"
DATABASE="ci_database"
POSTGRES_IMAGE="postgis/postgis:18-3.6"
TARGET="db:pg://ci:postgres@${CONTAINER_DB}:5432/${DATABASE}"
ROLES="gizmosql grafana postgraphile reccoom vibetype zammad"
SECRETS_DIR=""

echo "::group::Environment"
echo "Image: $IMAGE"
echo "Platform: $(uname -m)"
echo "Docker: $(docker --version 2>/dev/null || echo 'not found')"
echo "Suffix: $SUFFIX"
echo "::endgroup::"

cleanup() {
  echo "::group::Cleanup"
  echo "Removing containers and network..."
  docker rm --force "$CONTAINER_DB" >/dev/null 2>&1 || true
  docker network rm "$NETWORK" >/dev/null 2>&1 || true
  if [ -n "$SECRETS_DIR" ]; then
    rm -rf "$SECRETS_DIR" || true
  fi
  echo "Cleanup complete."
  echo "::endgroup::"
}
trap cleanup EXIT

fail() {
  echo "Assertion failed: $1"
  echo "Database logs:"
  docker logs "$CONTAINER_DB" || true
  exit 1
}

psql_db() {
  docker run --rm --network "$NETWORK" -e PGPASSWORD=postgres "$POSTGRES_IMAGE" \
    psql -h "$CONTAINER_DB" -U ci -d "$DATABASE" --tuples-only --no-align --command "$1"
}

# Runs the image the way production does: the entrypoint reads the target from
# /run/secrets/sqitch-target, and the role credentials are mounted as secrets.
run_image() {
  local mounts=()
  local file
  for file in "$SECRETS_DIR"/*; do
    mounts+=(--volume "$file:/run/secrets/$(basename "$file"):ro")
  done
  docker run --rm --network "$NETWORK" "${mounts[@]}" "$IMAGE" "$@"
}

echo "::group::Create secrets"
SECRETS_DIR="$(mktemp -d -p "$(pwd)" smoke-secrets.XXXXXX)"
chmod 755 "$SECRETS_DIR"
echo "$TARGET" > "$SECRETS_DIR/sqitch-target"
for role in $ROLES; do
  echo "$role" > "$SECRETS_DIR/postgres-role-service-${role}-username"
  echo "placeholder" > "$SECRETS_DIR/postgres-role-service-${role}-password"
done
chmod 644 "$SECRETS_DIR"/*
echo "Secrets ready."
echo "::endgroup::"

echo "::group::Create test network"
docker network inspect "$NETWORK" >/dev/null 2>&1 || docker network create "$NETWORK"
echo "Network ready."
echo "::endgroup::"

echo "::group::Start PostgreSQL"
docker run --detach --name "$CONTAINER_DB" \
  --network "$NETWORK" \
  -e POSTGRES_DB="$DATABASE" \
  -e POSTGRES_USER=ci \
  -e POSTGRES_PASSWORD=postgres \
  "$POSTGRES_IMAGE"

echo "Waiting for PostgreSQL to be ready..."
# pg_isready alone is not enough: the official postgres image briefly accepts
# connections on a temporary server (used to run init scripts and create
# POSTGRES_DB) before stopping and starting the final server. Querying the
# actual database catches that race instead of just checking the socket.
READY=""
for i in $(seq 1 60); do
  if psql_db 'SELECT 1' >/dev/null 2>&1; then
    echo "PostgreSQL is ready after ${i}s"
    READY=1
    break
  fi
  sleep 1
done
[ -n "$READY" ] || fail "timeout waiting for PostgreSQL to be ready"
echo "::endgroup::"

echo "::group::Deploy"
run_image sqitch deploy || fail "sqitch deploy failed"
echo "::endgroup::"

echo "::group::Verify deployment"
# A full `sqitch verify` is left out: the verify scripts check the state right
# after their own change, so later changes make them fail. `deploy.verify = true`
# in sqitch.conf already runs each script during the deploy above.
run_image sqitch status || fail "sqitch status failed"

SCHEMAS="$(psql_db "SELECT string_agg(nspname, ',' ORDER BY nspname) FROM pg_namespace WHERE nspname LIKE 'vibetype%'")"
echo "Schemas: $SCHEMAS"
[ "$SCHEMAS" = "vibetype,vibetype_private" ] || fail "expected schemas vibetype and vibetype_private"

for table in account event guest; do
  [ "$(psql_db "SELECT to_regclass('vibetype.$table') IS NOT NULL")" = "t" ] || fail "table vibetype.$table is missing"
done

for role in $ROLES; do
  [ "$(psql_db "SELECT EXISTS (SELECT FROM pg_roles WHERE rolname = '$role')")" = "t" ] || fail "role $role is missing"
done

# Deploying again must be a no-op rather than an error.
run_image sqitch deploy || fail "second sqitch deploy failed"
echo "Deployment OK."
echo "::endgroup::"

echo "::group::Revert"
run_image sqitch revert -y || fail "sqitch revert failed"

REMAINING="$(psql_db "SELECT count(*) FROM pg_namespace WHERE nspname LIKE 'vibetype%'")"
echo "Remaining app schemas: $REMAINING"
[ "$REMAINING" = "0" ] || fail "app schemas remain after revert"
for role in $ROLES; do
  [ "$(psql_db "SELECT EXISTS (SELECT FROM pg_roles WHERE rolname = '$role')")" = "f" ] || fail "role $role remains after revert"
done
echo "Revert OK."
echo "::endgroup::"

echo "::group::Database logs"
docker logs "$CONTAINER_DB" 2>&1 | tail -n 20
echo "::endgroup::"

echo "Smoke test passed."
