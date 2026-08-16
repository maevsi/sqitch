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

    # Wrap delta in parentheses when the absolute change is below the minimum threshold.
    (if $delta_abs != null and $delta_abs < $min_abs then
      "(" + ($delta_pct | format_delta) + ")"
    else
      ($delta_pct | format_delta)
    end) as $delta_display |

    def format_time:
      if . == -1 then "timeout :hourglass:"
      elif . == -2 then "error :x:"
      elif . < 0 then "skipped"
      else (. | tostring)
      end;

    {
      name: $name,
      role: $role,
      has_baseline: ($base_entry != null),
      base_total: (if $base_entry then ($base_entry.total_time_ms | format_time) else "—" end),
      pr_total: ($pr_total | format_time),
      delta: $delta_display,
      icon: $icon
    }
  ] as $rows |

  # Rows with no same-named query on the base side (new, renamed, or signature-changed
  # queries) cannot be compared at all; keep them separate instead of mixing them into
  # the delta buckets below.
  [$rows[] | select(.has_baseline)] as $compared_rows |
  [$rows[] | select(.has_baseline | not)] as $new_rows |
  ($new_rows | length) as $new_count |

  # Count regressions and errors
  [$compared_rows[] | select(.icon == " :warning:")] | length as $regression_count |
  [$rows[] | select(.base_total == "error :x:" or .pr_total == "error :x:")] as $error_rows |
  ($error_rows | length) as $error_count |

  # Relevant rows are those flagged as a regression or improvement; the rest are noise.
  [$compared_rows[] | select(.icon != "")] as $relevant_rows |
  [$compared_rows[] | select(.icon == "")] as $irrelevant_rows |
  ($irrelevant_rows | length) as $irrelevant_count |

  def render_table($table_rows):
    "| Query | Role | Base (ms) | PR (ms) | Delta |\n" +
    "|-------|------|-----------|---------|-------|\n" +
    ([$table_rows[] |
      "| `\(.name)` | \(.role | split("_") | last) | \(.base_total) | \(.pr_total) | \(.delta)\(.icon) |"
    ] | join("\n"));

  def render_new_table($table_rows):
    "| Query | Role | PR (ms) |\n" +
    "|-------|------|---------|\n" +
    ([$table_rows[] |
      "| `\(.name)` | \(.role | split("_") | last) | \(.pr_total) |"
    ] | join("\n"));

  # Build markdown
  "## Database Query Performance\n\n" +
  (if $regression_count > 0 then
    ":warning: **\($regression_count) potential regression(s) detected** (>" + ($threshold | tostring) + "% slower)\n\n"
  else
    ":white_check_mark: No significant regressions detected\n\n"
  end) +
  (if $error_count > 0 then
    ":x: **\($error_count) query/queries errored**\n\n"
  else ""
  end) +
  (if ($relevant_rows | length) > 0 then
    render_table($relevant_rows) + "\n\n"
  else ""
  end) +
  (if $new_count > 0 then
    "**\($new_count) quer" + (if $new_count == 1 then "y has" else "ies have" end) + " no baseline** (new or changed since the base branch, shown without a delta)\n\n" +
    render_new_table($new_rows) + "\n\n"
  else ""
  end) +
  (if $irrelevant_count > 0 then
    "<details>\n<summary>\($irrelevant_count) query/queries without a significant delta</summary>\n\n" +
    render_table($irrelevant_rows) +
    "\n\n</details>\n\n"
  else ""
  end) +
  "<details>\n<summary>Details</summary>\n\n" +
  "- Threshold for regression warnings: >\($threshold)% and ≥\($min_abs)ms absolute change\n" +
  "- Deltas in parentheses indicate that the absolute change is below the minimum threshold\n" +
  "- Each measurement discards the first (cold-cache) execution, then reports the median of all subsequent runs within a 5-second time budget\n" +
  "- Timings use clock_timestamp() with JIT compilation and synchronized sequential scans disabled\n" +
  "- Data: 1000 accounts, 100 events, 1000 contacts, ~1000 guests, 200 attendances\n" +
  "- Runner: GitHub Actions (timings may vary ±10% between runs)\n" +
  (if $run_url != "" then "- [Workflow run](\($run_url))\n" else "" end) +
  "\n</details>"
  ' -r > "$OUTPUT_FILE"

echo "Comparison written to $OUTPUT_FILE"
