#!/bin/sh
set -e

# Compares two benchmark JSON files and generates a Markdown report.
#
# Usage: compare.sh <base_results.json> <pr_results.json> <output.md> [run_url]

BASE_FILE="${1:?Usage: compare.sh <base.json> <pr.json> <output.md> [run_url]}"
PR_FILE="${2:?Usage: compare.sh <base.json> <pr.json> <output.md> [run_url]}"
OUTPUT_FILE="${3:?Usage: compare.sh <base.json> <pr.json> <output.md> [run_url]}"
RUN_URL="${4:-}"

REGRESSION_THRESHOLD=15
MINIMUM_ABSOLUTE_MS=1

jq -n \
  --argjson base "$(cat "$BASE_FILE")" \
  --argjson pr "$(cat "$PR_FILE")" \
  --argjson threshold "$REGRESSION_THRESHOLD" \
  --argjson min_abs "$MINIMUM_ABSOLUTE_MS" \
  --arg run_url "$RUN_URL" \
  '
  def format_delta:
    if . == null then "N/A"
    elif . > 0 then "+\(. | tostring)%"
    else "\(. | tostring)%"
    end;

  # Index base results by name+role
  ($base | map({key: "\(.name)|\(.role)", value: .}) | from_entries) as $base_map |

  # Build comparison rows
  [
    $pr[] |
    .name as $name |
    .role as $role |
    .total_time_ms as $pr_total |
    ($base_map["\($name)|\($role)"] // null) as $base_entry |
    (if $base_entry then $base_entry.total_time_ms else null end) as $base_total |
    (if $pr_total < 0 or ($base_total != null and $base_total < 0) then
      null
    elif $base_entry and $base_total > 0 then
      (($pr_total - $base_total) / $base_total * 100 | . * 10 | round / 10)
    else null end) as $delta_pct |
    (if $base_total != null and $pr_total >= 0 and $base_total >= 0 then
      (($pr_total - $base_total) | fabs)
    else null end) as $delta_abs |

    # Only flag regressions/improvements that exceed both the percentage AND absolute thresholds.
    (if $delta_pct == null or $delta_abs == null then ""
    elif ($delta_pct > $threshold) and ($delta_abs >= $min_abs) then " :warning:"
    elif ($delta_pct < (-1 * $threshold)) and ($delta_abs >= $min_abs) then " :rocket:"
    else ""
    end) as $icon |

    def format_time:
      if . == -1 then "timeout :hourglass:"
      elif . == -2 then "error :x:"
      elif . < 0 then "skipped"
      else (. | tostring)
      end;

    {
      name: $name,
      role: $role,
      base_total: (if $base_entry then ($base_entry.total_time_ms | format_time) else "—" end),
      pr_total: ($pr_total | format_time),
      delta: ($delta_pct | format_delta),
      icon: $icon
    }
  ] as $rows |

  # Count regressions and errors
  [$rows[] | select(.icon == " :warning:")] | length as $regression_count |
  [$rows[] | select(.base_total == "error :x:" or .pr_total == "error :x:")] as $error_rows |
  ($error_rows | length) as $error_count |

  # Build markdown
  "## Database Query Performance\n\n" +
  (if $regression_count > 0 then
    ":warning: **\($regression_count) potential regression(s) detected** (>" + ($threshold | tostring) + "% slower)\n\n"
  else
    ":white_check_mark: No significant regressions detected\n\n"
  end) +
  (if $error_count > 0 then
    ":x: **\($error_count) query/queries errored** (function signature mismatch between branches)\n\n"
  else ""
  end) +
  "| Query | Role | Base (ms) | PR (ms) | Delta |\n" +
  "|-------|------|-----------|---------|-------|\n" +
  ([$rows[] |
    "| `\(.name)` | \(.role | split("_") | last) | \(.base_total) | \(.pr_total) | \(.delta)\(.icon) |"
  ] | join("\n")) +
  "\n\n" +
  "<details>\n<summary>Details</summary>\n\n" +
  "- Threshold for regression warnings: >\($threshold)% and ≥\($min_abs)ms absolute change\n" +
  "- Each measurement discards the first (cold-cache) execution, then reports the median of all subsequent runs within a 5-second time budget\n" +
  "- Timings use clock_timestamp() with JIT compilation and synchronized sequential scans disabled\n" +
  "- Data: 1000 accounts, 100 events, 1000 contacts, ~1000 guests, 200 attendances\n" +
  "- Runner: GitHub Actions (timings may vary ±10% between runs)\n" +
  (if $run_url != "" then "- [Workflow run](\($run_url))\n" else "" end) +
  "\n</details>"
  ' -r > "$OUTPUT_FILE"

echo "Comparison written to $OUTPUT_FILE"
