BEGIN;

GRANT SELECT ON TABLE maevsi.event_upload TO maevsi_account, maevsi_anonymous;
GRANT INSERT, DELETE ON TABLE maevsi.event_upload TO maevsi_account;

ALTER TABLE maevsi.event_upload ENABLE ROW LEVEL SECURITY;

-- Only select rows for accessable events where accessability is specified
-- by the event_select policy for table event.
CREATE POLICY event_upload_select ON maevsi.event_upload FOR SELECT USING (
  event_id IN (
    SELECT id FROM maevsi.event
  )
);

-- Only allow inserts for events created by the current user and for uploads of the current_user.
CREATE POLICY event_upload_insert ON maevsi.event_upload FOR INSERT WITH CHECK (
  event_id IN (
    SELECT id FROM maevsi.event
    WHERE created_by = maevsi.invoker_account_id()
  )
  AND
  upload_id IN (
    SELECT id FROM maevsi.upload
    WHERE account_id = maevsi.invoker_account_id()
  )
);

-- Only allow deletes if event is created by the current user.
CREATE POLICY event_upload_delete ON maevsi.event_upload FOR DELETE USING (
  event_id IN (
    SELECT id FROM maevsi.event
    WHERE created_by = maevsi.invoker_account_id()
  )
);

COMMIT;
