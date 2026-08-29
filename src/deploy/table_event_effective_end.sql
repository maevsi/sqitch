BEGIN;

-- A plain generated column (rather than a computed function) so the filter plugin's
-- `connectionFilterComputedColumns: false` restriction doesn't apply: it's a real column,
-- filterable the same way `start`/`end` already are.
-- `'infinity'` stands in for "no explicit end", so events without one are never treated as
-- ended by a plain `effectiveEnd >= now` comparison; this replaces the client-side 12-hour
-- grace-period heuristic `maevsi/vibetype` used to fall back to.
ALTER TABLE vibetype.event
  ADD COLUMN effective_end timestamptz
  GENERATED ALWAYS AS (COALESCE("end", 'infinity'::timestamptz)) STORED;

COMMENT ON COLUMN vibetype.event.effective_end IS E'@behavior +filterBy\nThe event''s end date and time, falling back to `end of time` when no explicit end is set.';

COMMIT;
