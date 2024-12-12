BEGIN;

CREATE INDEX idx_event_grouping_event_id ON maevsi.event_grouping (event_id);

COMMENT ON INDEX maevsi.idx_event_grouping_event_id IS 'Speeds up reverse foreign key lookups.';

COMMIT;
