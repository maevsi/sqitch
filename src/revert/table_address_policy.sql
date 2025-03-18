BEGIN;

DROP POLICY address_delete ON vibetype.address;
DROP POLICY address_update ON vibetype.address;
DROP POLICY address_insert ON vibetype.address;
DROP POLICY address_select ON vibetype.address;

COMMIT;
