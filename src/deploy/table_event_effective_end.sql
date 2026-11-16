BEGIN;

-- A stored generated column defines the rule once and can be indexed, which an expression index cannot under row level security.
-- Following RFC 5545, an event without an explicit end ends at its start (zero duration).
ALTER TABLE vibetype.event
  ADD COLUMN effective_end timestamptz
  GENERATED ALWAYS AS (COALESCE("end", start)) STORED;

COMMENT ON COLUMN vibetype.event.effective_end IS E'@behavior -*\nThe event''s end date and time, falling back to its start when no explicit end is set.';

CREATE INDEX idx_event_start_effective_end ON vibetype.event USING btree (start, effective_end);
COMMENT ON INDEX vibetype.idx_event_start_effective_end IS 'B-Tree index serving the upcoming events list, which reads events in start order and skips ended ones inside the index.';

COMMIT;
