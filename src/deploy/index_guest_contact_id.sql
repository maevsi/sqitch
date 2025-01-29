BEGIN;

CREATE INDEX idx_guest_contact_id ON maevsi.guest(contact_id);

COMMENT ON INDEX maevsi.idx_guest_contact_id IS 'Speeds up reverse foreign key lookups.';

COMMIT;
