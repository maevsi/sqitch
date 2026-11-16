BEGIN;

-- A plain generated column (rather than a computed function) so the filter plugin's
-- `connectionFilterComputedColumns: false` restriction doesn't apply: it's a real column,
-- filterable the same way `start`/`end` already are.
-- Following RFC 5545, an event without an explicit end ends at its start (zero duration).
ALTER TABLE vibetype.event
  ADD COLUMN effective_end timestamptz
  GENERATED ALWAYS AS (COALESCE("end", start)) STORED;

COMMENT ON COLUMN vibetype.event.effective_end IS E'@behavior -insert -update +filterBy\nThe event''s end date and time, falling back to its start when no explicit end is set.';

COMMIT;
