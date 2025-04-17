BEGIN;

DROP POLICY upload_all_service ON vibetype.upload;
DROP POLICY upload_select ON vibetype.upload;

COMMIT;
