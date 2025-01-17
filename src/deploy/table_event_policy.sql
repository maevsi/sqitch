BEGIN;

GRANT SELECT ON TABLE maevsi.event TO maevsi_account, maevsi_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.event TO maevsi_account;

ALTER TABLE maevsi.event ENABLE ROW LEVEL SECURITY;

-- Only display events that are public and not full and not organized by a blocked account.
-- Only display events that are organized by oneself.
-- Only display events to which oneself is invited, but not by an invitation authored by a blocked account.
CREATE POLICY event_select ON maevsi.event FOR SELECT USING (
  (
    visibility = 'public'
    AND
    (
      invitee_count_maximum IS NULL
      OR
      invitee_count_maximum > (maevsi.invitee_count(id)) -- Using the function here is required as there would otherwise be infinite recursion.
    )
    AND author_account_id NOT IN (
      SELECT blocked_account_id
      FROM maevsi.account_block
      WHERE author_account_id = maevsi.invoker_account_id()
      UNION ALL
      SELECT author_account_id
      FROM maevsi.account_block
      WHERE blocked_account_id = maevsi.invoker_account_id()
    )
  )
  OR (
    author_account_id = maevsi.invoker_account_id()
  )
  OR (
    id IN (SELECT maevsi_private.events_invited())
  )
);

-- Only allow inserts for events authored by the current user.
CREATE POLICY event_insert ON maevsi.event FOR INSERT WITH CHECK (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  author_account_id = maevsi.invoker_account_id()
);

-- Only allow updates for events authored by the current user.
CREATE POLICY event_update ON maevsi.event FOR UPDATE USING (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  author_account_id = maevsi.invoker_account_id()
);

COMMIT;
