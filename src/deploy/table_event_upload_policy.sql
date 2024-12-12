-- Deploy maevsi:table_event_upload_policy to pg

BEGIN;

GRANT SELECT ON TABLE maevsi.event_upload TO maevsi_account, maevsi_anonymous;
GRANT INSERT, DELETE ON TABLE maevsi.event_upload TO maevsi_account;

ALTER TABLE maevsi.event_upload ENABLE ROW LEVEL SECURITY;

-- Only select rows with events authored by the current user.
CREATE POLICY event_upload_select ON maevsi.event_upload FOR SELECT USING (
  event_id IN (
    SELECT id FROM maevsi.event
    WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
  )
);

-- Only allow inserts for events authored by the current user und uploads of the current_user0.
CREATE POLICY event_upload_insert ON maevsi.event_upload FOR INSERT WITH CHECK (
  event_id IN (
    SELECT id FROM maevsi.event
    WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
  )
  AND
  upload_id IN (
    SELECT id FROM maevsi.upload
    WHERE account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
  )
);

-- Only allow deletes if events is authored by the current user und uploads of the current_user.
CREATE POLICY event_upload_delete ON maevsi.event_upload FOR DELETE USING (
  event_id IN (
    SELECT id FROM maevsi.event
    WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
  )
);

COMMIT;