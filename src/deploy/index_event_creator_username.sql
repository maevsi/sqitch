BEGIN;

CREATE INDEX idx_event_created_by ON vibetype.event (created_by);

COMMENT ON INDEX vibetype.idx_event_created_by IS 'Speeds up reverse foreign key lookups.';

COMMIT;
