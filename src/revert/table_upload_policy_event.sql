BEGIN;

DROP POLICY upload_select_event ON vibetype.upload;

DROP POLICY event_upload_insert ON vibetype.event_upload;
CREATE POLICY event_upload_insert ON vibetype.event_upload FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM vibetype.event e
    WHERE e.id = event_upload.event_id
      AND e.created_by = vibetype.invoker_account_id()
  )
  AND
  EXISTS (
    SELECT 1 FROM vibetype.upload u
    WHERE u.id = event_upload.upload_id
      AND u.created_by = vibetype.invoker_account_id()
  )
);

COMMIT;
