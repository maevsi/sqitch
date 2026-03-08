#!/usr/bin/env bash
set -euo pipefail

# Runs benchmark queries against a PostgreSQL database with deployed migrations
# and benchmark seed data. Outputs a JSON file with timing results.
#
# Usage: run.sh <output_file> [pg_connection_string]
#
# The script:
# 1. Creates the vibetype_test schema and benchmark helper functions
# 2. Seeds benchmark data
# 3. Runs benchmark queries, capturing timing output
# 4. Extracts JSON results to the output file

OUTPUT_FILE="${1:?Usage: run.sh <output_file> [pg_connection_string]}"
PG_URI="${2:-db:pg://ci:postgres@localhost/ci_database}"

# Strip the db: prefix if present (Sqitch format vs psql format) and normalize pg:// to postgresql://
PSQL_URI=$(echo "$PG_URI" | sed -e 's|^db:||' -e 's|^pg://|postgresql://|')

THIS=$(dirname "$(readlink -f "$0")")

echo "Running benchmarks..."

# Create test schema and seed data
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on <<'EOF'
DROP SCHEMA IF EXISTS vibetype_test CASCADE;
CREATE SCHEMA vibetype_test;
GRANT USAGE ON SCHEMA vibetype_test TO vibetype_anonymous, vibetype_account;
EOF

# Seed benchmark data
echo "Seeding benchmark data..."
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on --file "$THIS/seed.sql"

# Run ANALYZE to ensure query planner has up-to-date statistics
echo "Running ANALYZE..."
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on -c "ANALYZE;"
echo "ANALYZE complete."

# Run benchmark queries — tee to temp file for extraction while showing progress
echo "Running benchmark queries..."
BENCHMARK_TMPFILE=$(mktemp)
psql "$PSQL_URI" --variable ON_ERROR_STOP=on --file "$THIS/queries.sql" 2>&1 | tee "$BENCHMARK_TMPFILE"
echo "Benchmark queries complete."

# Extract JSON lines between the markers
sed -n '/--- BEGIN BENCHMARK RESULTS ---/,/--- END BENCHMARK RESULTS ---/p' "$BENCHMARK_TMPFILE" \
  | grep '^{' \
  | jq -s '.' > "$OUTPUT_FILE"

rm "$BENCHMARK_TMPFILE"

# Cleanup
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on -c "DROP SCHEMA IF EXISTS vibetype_test CASCADE;"

RESULT_COUNT=$(jq 'length' "$OUTPUT_FILE")
echo "Benchmark complete: $RESULT_COUNT measurements written to $OUTPUT_FILE"
