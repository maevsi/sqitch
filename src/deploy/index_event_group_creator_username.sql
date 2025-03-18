BEGIN;

CREATE INDEX idx_event_group_created_by ON vibetype.event_group (created_by);

COMMENT ON INDEX vibetype.idx_event_group_created_by IS 'Speeds up reverse foreign key lookups.';

COMMIT;
