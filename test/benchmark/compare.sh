#!/bin/sh
set -e

# Compares two benchmark JSON files and generates a Markdown table for a PR comment.
#
# Usage: compare.sh <base_results.json> <pr_results.json> <output.md>
#
# The JSON files are arrays of objects with: name, role, execution_time_ms, total_time_ms

BASE_FILE="${1:?Usage: compare.sh <base.json> <pr.json> <output.md>}"
PR_FILE="${2:?Usage: compare.sh <base.json> <pr.json> <output.md>}"
OUTPUT_FILE="${3:?Usage: compare.sh <base.json> <pr.json> <output.md>}"

REGRESSION_THRESHOLD=15

jq -n \
  --argjson base "$(cat "$BASE_FILE")" \
  --argjson pr "$(cat "$PR_FILE")" \
  --argjson threshold "$REGRESSION_THRESHOLD" \
  '
  def format_delta:
    if . == null then "N/A"
    elif . > 0 then "+\(. | tostring)%"
    else "\(. | tostring)%"
    end;

  def status_icon:
    if . == null then ""
    elif . > $threshold then " :warning:"
    elif . < (-1 * $threshold) then " :rocket:"
    else ""
    end;

  # Index base results by name+role
  ($base | map({key: "\(.name)|\(.role)", value: .}) | from_entries) as $base_map |

  # Build comparison rows
  [
    $pr[] |
    .name as $name |
    .role as $role |
    .total_time_ms as $pr_total |
    .execution_time_ms as $pr_execution |
    ($base_map["\($name)|\($role)"] // null) as $base_entry |
    (if $base_entry then $base_entry.total_time_ms else null end) as $base_total |
    (if $pr_total < 0 or ($base_total != null and $base_total < 0) then
      null
    elif $base_entry and $base_total > 0 then
      (($pr_total - $base_total) / $base_total * 100 | . * 10 | round / 10)
    else null end) as $delta_pct |

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
      icon: ($delta_pct | status_icon)
    }
  ] as $rows |

  # Count regressions
  [$rows[] | select(.icon == " :warning:")] | length as $regression_count |

  # Build markdown
  "## Database Query Performance\n\n" +
  (if $regression_count > 0 then
    ":warning: **\($regression_count) potential regression(s) detected** (>" + ($threshold | tostring) + "% slower)\n\n"
  else
    ":white_check_mark: No significant regressions detected\n\n"
  end) +
  "| Query | Role | Base (ms) | PR (ms) | Delta |\n" +
  "|-------|------|-----------|---------|-------|\n" +
  ([$rows[] |
    "| `\(.name)` | \(.role | split("_") | last) | \(.base_total) | \(.pr_total) | \(.delta)\(.icon) |"
  ] | join("\n")) +
  "\n\n" +
  "<details>\n<summary>Details</summary>\n\n" +
  "- Threshold for regression warnings: >\($threshold)%\n" +
  "- Each measurement is the median of 11 runs with adaptive iteration counts (~500ms target per run)\n" +
  "- Timings are per-iteration averages measured via clock_timestamp()\n" +
  "- Data: 1000 accounts, 100 events, 1000 contacts, ~1000 guests, 200 attendances\n" +
  "- Runner: GitHub Actions (timings may vary ±10% between runs)\n\n" +
  "</details>"
  ' -r > "$OUTPUT_FILE"

echo "Comparison written to $OUTPUT_FILE"
