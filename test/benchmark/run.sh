#!/usr/bin/env bash
set -euo pipefail

# Runs benchmark queries and outputs a JSON file with timing results.
#
# Usage: run.sh <output_file> [pg_connection_string]

OUTPUT_FILE="${1:?Usage: run.sh <output_file> [pg_connection_string]}"
PG_URI="${2:-db:pg://ci:postgres@localhost/ci_database}"

PSQL_URI=$(echo "$PG_URI" | sed -e 's|^db:||' -e 's|^pg://|postgresql://|')

THIS=$(dirname "$(readlink -f "$0")")

echo "Preparing benchmark schema..."
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on <<'EOF'
DROP SCHEMA IF EXISTS vibetype_test CASCADE;
CREATE SCHEMA vibetype_test;
GRANT USAGE ON SCHEMA vibetype_test TO vibetype_anonymous, vibetype_account;
EOF

echo "Seeding benchmark data..."
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on --file "$THIS/seed.sql"

echo "Running ANALYZE..."
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on -c "ANALYZE;"

echo "Running benchmark queries..."
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on --file "$THIS/queries.sql" > "$OUTPUT_FILE"

psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on -c "DROP SCHEMA IF EXISTS vibetype_test CASCADE;"

RESULT_COUNT=$(jq 'length' "$OUTPUT_FILE")
echo "Benchmark complete: $RESULT_COUNT measurements written to $OUTPUT_FILE"
