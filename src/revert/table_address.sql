BEGIN;

DROP TRIGGER maevsi_trigger_address_update ON maevsi.address;

DROP TABLE maevsi.address;

COMMIT;
