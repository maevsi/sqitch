BEGIN;

DROP POLICY event_upload_delete ON vibetype.event_upload;
DROP POLICY event_upload_insert ON vibetype.event_upload;
DROP POLICY event_upload_select ON vibetype.event_upload;

DROP TABLE vibetype.event_upload;

COMMIT;
