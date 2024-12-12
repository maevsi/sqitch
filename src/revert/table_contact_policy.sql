BEGIN;

DROP POLICY contact_delete ON maevsi.contact;
DROP POLICY contact_update ON maevsi.contact;
DROP POLICY contact_insert ON maevsi.contact;
DROP POLICY contact_select ON maevsi.contact;

COMMIT;
