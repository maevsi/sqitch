BEGIN;

GRANT SELECT ON TABLE maevsi.event_category_mapping TO maevsi_anonymous;
GRANT SELECT, INSERT, DELETE ON TABLE maevsi.event_category_mapping TO maevsi_account;

ALTER TABLE maevsi.event_category_mapping ENABLE ROW LEVEL SECURITY;

-- Allow selects for events authored by the current user.
-- Allow events that are public or that the user is invited to, but exclude events
-- created by a blocked user and events created by a user who blocked the current user.
CREATE POLICY event_category_mapping_select ON maevsi.event_category_mapping FOR SELECT USING (
  (
    maevsi.invoker_account_id() IS NOT NULL
    AND (
      (SELECT author_account_id FROM maevsi.event WHERE id = event_id) = maevsi.invoker_account_id()
    )
  )
  OR
      event_id IN (SELECT maevsi_private.events_invited())
  OR (
    (SELECT visibility FROM maevsi.event WHERE id = event_id) = 'public'
    AND (SELECT author_account_id FROM maevsi.event WHERE id = event_id) NOT IN (
      SELECT blocked_account_id
      FROM maevsi.account_block
      WHERE author_account_id = maevsi.invoker_account_id()
      UNION ALL
      SELECT author_account_id
      FROM maevsi.account_block
      WHERE blocked_account_id = maevsi.invoker_account_id()
    )
  )
);

-- Only allow inserts for events authored by user.
CREATE POLICY event_category_mapping_insert ON maevsi.event_category_mapping FOR INSERT WITH CHECK (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  (SELECT author_account_id FROM maevsi.event WHERE id = event_id) = maevsi.invoker_account_id()
);

-- Only allow deletes for events authored by user.
CREATE POLICY event_category_mapping_delete ON maevsi.event_category_mapping FOR DELETE USING (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  (SELECT author_account_id FROM maevsi.event WHERE id = event_id) = maevsi.invoker_account_id()
);

COMMIT;
