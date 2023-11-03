-- Revert maevsi:table_upload from pg

BEGIN;

DROP POLICY upload_delete_using ON maevsi.upload;
DROP POLICY upload_select_using ON maevsi.upload;
DROP POLICY upload_update_using ON maevsi.upload;

COMMIT;
