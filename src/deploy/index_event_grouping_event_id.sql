BEGIN;

CREATE INDEX idx_event_grouping_event_id ON vibetype.event_grouping (event_id);

COMMENT ON INDEX vibetype.idx_event_grouping_event_id IS 'Speeds up reverse foreign key lookups.';

COMMIT;
