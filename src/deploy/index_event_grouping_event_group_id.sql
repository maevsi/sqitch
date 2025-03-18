BEGIN;

CREATE INDEX idx_event_grouping_event_group_id ON vibetype.event_grouping (event_group_id);

COMMENT ON INDEX vibetype.idx_event_grouping_event_group_id IS 'Speeds up reverse foreign key lookups.';

COMMIT;
