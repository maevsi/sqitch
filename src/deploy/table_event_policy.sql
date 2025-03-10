BEGIN;

GRANT SELECT ON TABLE vibetype.event TO vibetype_account, vibetype_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE vibetype.event TO vibetype_account;

ALTER TABLE vibetype.event ENABLE ROW LEVEL SECURITY;

-- Only display events that are public and not full and not organized by a blocked account.
-- Only display events that are organized by oneself.
-- Only display events to which oneself is invited, but not by a guest created by a blocked account.
CREATE POLICY event_select ON vibetype.event FOR SELECT USING (
  (
    visibility = 'public'
    AND
    (
      guest_count_maximum IS NULL
      OR
      guest_count_maximum > (vibetype.guest_count(id)) -- Using the function here is required as there would otherwise be infinite recursion.
    )
    AND created_by NOT IN (
      SELECT id FROM vibetype_private.account_block_ids()
    )
  )
  OR (
    created_by = vibetype.invoker_account_id()
  )
  OR (
    id IN (SELECT vibetype_private.events_invited())
  )
);

-- Only allow inserts for events created by the current user.
CREATE POLICY event_insert ON vibetype.event FOR INSERT WITH CHECK (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  created_by = vibetype.invoker_account_id()
);

-- Only allow updates for events created by the current user.
CREATE POLICY event_update ON vibetype.event FOR UPDATE USING (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  created_by = vibetype.invoker_account_id()
);

-- Only allow deletes for events created by the current user.
CREATE POLICY event_delete ON vibetype.event FOR DELETE USING (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
