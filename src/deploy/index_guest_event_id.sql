BEGIN;

CREATE INDEX idx_guest_event_id ON vibetype.guest (event_id);

COMMENT ON INDEX vibetype.idx_guest_event_id IS 'Speeds up reverse foreign key lookups.';

COMMIT;
