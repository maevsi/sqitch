#!/usr/bin/env bash
set -euo pipefail

# Runs a concurrent pgbench load test against the seeded benchmark schema
# and writes a human-readable report. See test/benchmark/pgbench/README.md
# for how this differs from run.sh/queries.sql.
#
# Usage: load.sh <output_file> [superuser_pg_uri] [postgraphile_pg_uri] [duration_seconds] [clients] [jobs]

OUTPUT_FILE="${1:?Usage: load.sh <output_file> [superuser_pg_uri] [postgraphile_pg_uri] [duration_seconds] [clients] [jobs]}"
SUPERUSER_PG_URI="${2:-db:pg://ci:postgres@localhost/ci_database}"
POSTGRAPHILE_PG_URI="${3:-db:pg://postgraphile:placeholder@localhost/ci_database}"
DURATION="${4:-30}"
CLIENTS="${5:-10}"
JOBS="${6:-2}"

SUPERUSER_PSQL_URI=$(echo "$SUPERUSER_PG_URI" | sed -e 's|^db:||' -e 's|^pg://|postgresql://|')
POSTGRAPHILE_PSQL_URI=$(echo "$POSTGRAPHILE_PG_URI" | sed -e 's|^db:||' -e 's|^pg://|postgresql://|')

THIS=$(dirname "$(readlink -f "$0")")

echo "Seeding benchmark data..."
psql "$SUPERUSER_PSQL_URI" --quiet --variable ON_ERROR_STOP=on --file "$THIS/seed.sql" > /dev/null

echo "Resolving benchmark subject IDs..."
ACCOUNT_ID=$(psql "$SUPERUSER_PSQL_URI" --quiet --tuples-only --no-align --variable ON_ERROR_STOP=on \
  -c "SELECT id FROM vibetype.account WHERE username = 'benchmark-user-1';")
EVENT_ID=$(psql "$SUPERUSER_PSQL_URI" --quiet --tuples-only --no-align --variable ON_ERROR_STOP=on \
  -c "SELECT id FROM vibetype.event WHERE slug = 'benchmark-event-1';")

echo "Running ANALYZE..."
psql "$SUPERUSER_PSQL_URI" --quiet --variable ON_ERROR_STOP=on -c "ANALYZE;"

echo "Running pgbench (clients=$CLIENTS jobs=$JOBS duration=${DURATION}s)..."
pgbench \
  --client="$CLIENTS" \
  --jobs="$JOBS" \
  --time="$DURATION" \
  --no-vacuum \
  --report-per-command \
  --define=account_id="$ACCOUNT_ID" \
  --define=event_id="$EVENT_ID" \
  --file="$THIS/pgbench/select_events_anonymous.sql@4" \
  --file="$THIS/pgbench/select_events_account.sql@3" \
  --file="$THIS/pgbench/event_search_anonymous.sql@3" \
  --file="$THIS/pgbench/event_search_account.sql@2" \
  --file="$THIS/pgbench/guest_count_anonymous.sql@2" \
  --file="$THIS/pgbench/guest_count_account.sql@2" \
  --file="$THIS/pgbench/account_search_account.sql@1" \
  "$POSTGRAPHILE_PSQL_URI" | tee "$OUTPUT_FILE"

echo "Load benchmark complete: report written to $OUTPUT_FILE"
