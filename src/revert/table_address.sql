BEGIN;

DROP POLICY address_all ON vibetype.address;

DROP TRIGGER vibetype_trigger_address_update ON vibetype.address;

DROP INDEX vibetype.idx_address_updated_by;
DROP INDEX vibetype.idx_address_created_by;
DROP INDEX vibetype.idx_address_location;
DROP TABLE vibetype.address;

COMMIT;
