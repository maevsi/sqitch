#!/bin/sh
set -e

THIS=$(dirname "$(readlink -f "$0")")
ROOT="$THIS/../.."
IMAGE="maevsi/sqitch"

usage() {
  echo "Usage: $0 [--compare]"
  echo ""
  echo "  (default)   Run benchmarks on the current branch"
  echo "  --compare   Run benchmarks on the current branch and the merge base,"
  echo "              then output a comparison report"
  exit 1
}

run_benchmark() {
  local label="$1"
  local output_file="$2"

  echo "[$label] Building benchmark Docker stage..."
  sudo docker build -t "$IMAGE:benchmark-$label" --target benchmark "$ROOT" # --no-cache --progress plain

  echo "[$label] Extracting results..."
  CONTAINER_ID=$(sudo docker create "$IMAGE:benchmark-$label")
  sudo docker cp "$CONTAINER_ID:/srv/app/benchmark_results.json" "$output_file"
  sudo docker rm -v "$CONTAINER_ID" > /dev/null

  echo "[$label] Results saved to $output_file"
}

case "$1" in
  --compare)
    CURRENT_BRANCH=$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)
    BASE_BRANCH=$(git -C "$ROOT" merge-base HEAD main)

    echo "Benchmarking current branch ($CURRENT_BRANCH)..."
    run_benchmark "pr" "/tmp/benchmark_pr.json"

    echo ""
    echo "Benchmarking base ($(git -C "$ROOT" log --oneline -1 "$BASE_BRANCH"))..."
    git -C "$ROOT" stash --include-untracked --quiet 2>/dev/null || true
    git -C "$ROOT" checkout --quiet "$BASE_BRANCH"
    run_benchmark "base" "/tmp/benchmark_base.json"
    git -C "$ROOT" checkout --quiet "$CURRENT_BRANCH"
    git -C "$ROOT" stash pop --quiet 2>/dev/null || true

    echo ""
    echo "Generating comparison..."
    "$THIS/compare.sh" /tmp/benchmark_base.json /tmp/benchmark_pr.json /tmp/benchmark_comparison.md

    echo ""
    cat /tmp/benchmark_comparison.md
    ;;
  "")
    run_benchmark "current" "/tmp/benchmark_results.json"
    echo ""
    echo "Results:"
    jq -r '["Query","Role","Time (ms)"], ["---","---","---"], (.[] | [.name, (.role | split("_") | last), .total_time_ms]) | @tsv' /tmp/benchmark_results.json | column -t -s $'\t'
    ;;
  *)
    usage
    ;;
esac
