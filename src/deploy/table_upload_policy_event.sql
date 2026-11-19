BEGIN;

-- Reading `upload` under its policies here would recurse into `event_upload` through `upload_select_event`.
DROP POLICY event_upload_insert ON vibetype.event_upload;
CREATE POLICY event_upload_insert ON vibetype.event_upload FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM vibetype.event e
    WHERE e.id = event_upload.event_id
      AND e.created_by = vibetype.invoker_account_id()
  )
  AND
  vibetype_private.upload_is_own(event_upload.upload_id)
);

-- Display the uploads of every event that the `event_upload_select` policy displays.
CREATE POLICY upload_select_event ON vibetype.upload FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM vibetype.event_upload eu
    WHERE eu.upload_id = upload.id
  )
);

COMMIT;
