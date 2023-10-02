-- Revert maevsi:table_upload from pg

BEGIN;

DROP POLICY upload_delete ON maevsi.event;
DROP POLICY upload_select ON maevsi.event;
DROP POLICY upload_update ON maevsi.event;

COMMIT;
