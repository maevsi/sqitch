BEGIN;

GRANT SELECT ON TABLE maevsi.event TO maevsi_account, maevsi_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.event TO maevsi_account;

ALTER TABLE maevsi.event ENABLE ROW LEVEL SECURITY;

-- Only display events that are public and not full and not organized by a blocked account.
-- Only display events that are organized by oneself.
-- Only display events to which oneself is invited, but not by an invitation created by a blocked account.
CREATE POLICY event_select ON maevsi.event FOR SELECT USING (
  (
    visibility = 'public'
    AND
    (
      invitee_count_maximum IS NULL
      OR
      invitee_count_maximum > (maevsi.invitee_count(id)) -- Using the function here is required as there would otherwise be infinite recursion.
    )
    AND created_by NOT IN (
      SELECT id FROM maevsi_private.account_block_ids()
    )
  )
  OR (
    created_by = maevsi.invoker_account_id()
  )
  OR (
    id IN (SELECT maevsi_private.events_invited())
  )
);

-- Only allow inserts for events created by the current user.
CREATE POLICY event_insert ON maevsi.event FOR INSERT WITH CHECK (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  created_by = maevsi.invoker_account_id()
);

-- Only allow updates for events created by the current user.
CREATE POLICY event_update ON maevsi.event FOR UPDATE USING (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  created_by = maevsi.invoker_account_id()
);

-- Only allow deletes for events created by the current user.
CREATE POLICY event_delete ON maevsi.event FOR DELETE USING (
  created_by = maevsi.invoker_account_id()
);

COMMIT;
