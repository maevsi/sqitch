BEGIN;

DROP TRIGGER maevsi_trigger_address_update ON maevsi.address;
DROP INDEX maevsi.idx_address_updated_by;
DROP INDEX maevsi.idx_address_created_by;
DROP INDEX maevsi.idx_address_location;
DROP TABLE maevsi.address;

COMMIT;
