-- Deploy maevsi:table_event_category_mapping_policy to pg

BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.event_category_mapping TO maevsi_account;

-- Only allow selects for events authored by user, events that are public or that the user is invited to.
CREATE POLICY event_category_mapping_select ON maevsi.event_category_mapping FOR SELECT USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND (
    event_id = (SELECT id FROM maevsi.event WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID)
    OR
    visibility = 'public'
  )
);

-- Only allow inserts for events authored by user.
CREATE POLICY event_category_mapping_insert ON maevsi.event_category_mapping FOR INSERT CHECK (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  event_id = (SELECT id FROM maevsi.event WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID)
);

-- Only allow deletes for events authored by user.
CREATE POLICY event_category_mapping_delete ON maevsi.event_category_mapping FOR DELETE USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  event_id = (SELECT id FROM maevsi.event WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID)
);

COMMIT;