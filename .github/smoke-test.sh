#!/usr/bin/env bash
set -euo pipefail

IMAGE="${SMOKE_TEST_IMAGE:?SMOKE_TEST_IMAGE not set}"
SUFFIX="${GITHUB_RUN_ID:-$$}-${GITHUB_RUN_ATTEMPT:-1}"
CONTAINER_DB="smoke-db-${SUFFIX}"
NETWORK="smoke-${SUFFIX}"
DATABASE="ci_database"
POSTGRES_IMAGE="ghcr.io/maevsi/postgres:1.0.0"
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

# The Dockerfile's test stage already deploys, diffs the schema, runs the logic tests and reverts,
# but with Debian's sqitch and without the entrypoint, so this only covers what the published image adds.
echo "::group::Deploy with the default command"
run_image || fail "the default command failed"
echo "::endgroup::"

echo "::group::Check status"
STATUS="$(run_image sqitch status)" || fail "sqitch status failed"
echo "$STATUS"
grep -q 'Nothing to deploy (up-to-date)' <<<"$STATUS" || fail "the deployment is incomplete"
echo "::endgroup::"

echo "::group::Database logs"
docker logs "$CONTAINER_DB" 2>&1 | tail -n 20
echo "::endgroup::"

echo "Smoke test passed."
