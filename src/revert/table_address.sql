BEGIN;

DROP TRIGGER vibetype_trigger_address_update ON vibetype.address;

DROP TABLE vibetype.address;

COMMIT;
