-- Deploy maevsi:table_event_category_mapping_policy to pg
-- requires: schema_public
-- requires: table_event_category_mapping
-- requires: role_anonymous
-- requires: role_account
-- requires: table_event

BEGIN;

GRANT SELECT ON TABLE maevsi.event_category_mapping TO maevsi_anonymous;
GRANT SELECT, INSERT, DELETE ON TABLE maevsi.event_category_mapping TO maevsi_account;

ALTER TABLE maevsi.event_category_mapping ENABLE ROW LEVEL SECURITY;

-- Only allow selects for events authored by user, events that are public or that the user is invited to.
-- Exclude events created by a blocked user and invitated events where the invation comes form a blocked user.
CREATE POLICY event_category_mapping_select ON maevsi.event_category_mapping FOR SELECT USING (
  (
    NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
    AND (
      (SELECT author_account_id FROM maevsi.event WHERE id = event_id) = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
    )
  )
  OR
      event_id IN (SELECT maevsi_private.events_invited())
  -- TODO: condition using table maevsi.account_block to be added later
/*
    AND
    (SELECT visibility FROM maevsi.event WHERE id = event_id) = 'public'
        AND event_id NOT IN (
        SELECT e.event_id
        FROM maevsi.event e JOIN maevsi.account_block b ON e.account_id = b.blocked_account_id
        WHERE b.account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
    )
*/
);

-- Only allow inserts for events authored by user.
CREATE POLICY event_category_mapping_insert ON maevsi.event_category_mapping FOR INSERT WITH CHECK (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  (SELECT author_account_id FROM maevsi.event WHERE id = event_id) = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow deletes for events authored by user.
CREATE POLICY event_category_mapping_delete ON maevsi.event_category_mapping FOR DELETE USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  (SELECT author_account_id FROM maevsi.event WHERE id = event_id) = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

COMMIT;
