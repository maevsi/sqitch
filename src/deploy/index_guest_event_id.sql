BEGIN;

CREATE INDEX idx_guest_event_id ON maevsi.guest (event_id);

COMMENT ON INDEX maevsi.idx_guest_event_id IS 'Speeds up reverse foreign key lookups.';

COMMIT;
