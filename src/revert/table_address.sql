BEGIN;

DROP TRIGGER update ON vibetype.address;

DROP INDEX vibetype.idx_address_updated_by;
DROP INDEX vibetype.idx_address_created_by;
DROP INDEX vibetype.idx_address_location;
DROP TABLE vibetype.address;

COMMIT;
