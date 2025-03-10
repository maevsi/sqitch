BEGIN;

DROP POLICY upload_delete_using ON vibetype.upload;
DROP POLICY upload_update_using ON vibetype.upload;
DROP POLICY upload_select_using ON vibetype.upload;

COMMIT;
