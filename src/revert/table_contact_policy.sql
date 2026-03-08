BEGIN;

DROP POLICY contact_delete ON vibetype.contact;
DROP POLICY contact_update ON vibetype.contact;
DROP POLICY contact_insert ON vibetype.contact;
DROP POLICY contact_select ON vibetype.contact;
DROP FUNCTION vibetype_private.contact_policy_select(vibetype.contact);

COMMIT;
