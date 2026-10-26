BEGIN;

DROP POLICY address_delete_creator ON vibetype.address;
DROP POLICY address_update_creator ON vibetype.address;

COMMIT;
