BEGIN;

CREATE INDEX idx_event_created_by ON maevsi.event (created_by);

COMMENT ON INDEX maevsi.idx_event_created_by IS 'Speeds up reverse foreign key lookups.';

COMMIT;
