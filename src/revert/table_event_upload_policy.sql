BEGIN;

DROP POLICY event_upload_select ON maevsi.event_upload;
DROP POLICY event_upload_insert ON maevsi.event_upload;
DROP POLICY event_upload_delete ON maevsi.event_upload;

COMMIT;
