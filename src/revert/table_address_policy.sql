BEGIN;

DROP POLICY address_delete ON maevsi.address;
DROP POLICY address_update ON maevsi.address;
DROP POLICY address_insert ON maevsi.address;
DROP POLICY address_select ON maevsi.address;

COMMIT;
