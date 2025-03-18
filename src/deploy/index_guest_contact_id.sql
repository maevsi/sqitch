BEGIN;

CREATE INDEX idx_guest_contact_id ON vibetype.guest(contact_id);

COMMENT ON INDEX vibetype.idx_guest_contact_id IS 'Speeds up reverse foreign key lookups.';

COMMIT;
