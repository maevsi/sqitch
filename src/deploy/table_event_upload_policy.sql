BEGIN;

GRANT SELECT ON TABLE vibetype.event_upload TO vibetype_account, vibetype_anonymous;
GRANT INSERT, DELETE ON TABLE vibetype.event_upload TO vibetype_account;

ALTER TABLE vibetype.event_upload ENABLE ROW LEVEL SECURITY;

-- Only select rows for accessable events where accessability is specified
-- by the event_select policy for table event.
CREATE POLICY event_upload_select ON vibetype.event_upload FOR SELECT USING (
  event_id IN (
    SELECT id FROM vibetype.event
  )
);

-- Only allow inserts for events created by the current user and for uploads of the current_user.
CREATE POLICY event_upload_insert ON vibetype.event_upload FOR INSERT WITH CHECK (
  event_id IN (
    SELECT id FROM vibetype.event
    WHERE created_by = vibetype.invoker_account_id()
  )
  AND
  upload_id IN (
    SELECT id FROM vibetype.upload
    WHERE account_id = vibetype.invoker_account_id()
  )
);

-- Only allow deletes if event is created by the current user.
CREATE POLICY event_upload_delete ON vibetype.event_upload FOR DELETE USING (
  event_id IN (
    SELECT id FROM vibetype.event
    WHERE created_by = vibetype.invoker_account_id()
  )
);

COMMIT;
