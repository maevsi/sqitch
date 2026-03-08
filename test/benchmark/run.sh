#!/bin/sh
set -e

# Runs benchmark queries against a PostgreSQL database with deployed migrations
# and benchmark seed data. Outputs a JSON file with timing results.
#
# Usage: run.sh <output_file> [pg_connection_string]
#
# The script:
# 1. Creates the vibetype_test schema and benchmark helper functions
# 2. Seeds benchmark data
# 3. Runs benchmark queries, capturing EXPLAIN ANALYZE output
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
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on --file "$THIS/seed.sql"

# Run ANALYZE to ensure query planner has up-to-date statistics
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on -c "ANALYZE;"

# Run benchmark queries and capture output (stderr still goes to console for visibility)
BENCHMARK_OUTPUT=$(psql "$PSQL_URI" --variable ON_ERROR_STOP=on --file "$THIS/queries.sql")

# Extract JSON lines between the markers
echo "$BENCHMARK_OUTPUT" \
  | sed -n '/--- BEGIN BENCHMARK RESULTS ---/,/--- END BENCHMARK RESULTS ---/p' \
  | grep '^{' \
  | jq -s '.' > "$OUTPUT_FILE"

# Cleanup
psql "$PSQL_URI" --quiet --variable ON_ERROR_STOP=on -c "DROP SCHEMA IF EXISTS vibetype_test CASCADE;"

RESULT_COUNT=$(jq 'length' "$OUTPUT_FILE")
echo "Benchmark complete: $RESULT_COUNT measurements written to $OUTPUT_FILE"
