BEGIN;

DROP INDEX maevsi.idx_guest_event_id;
DROP INDEX maevsi.idx_guest_contact_id;
DROP TABLE maevsi.guest;

COMMIT;
