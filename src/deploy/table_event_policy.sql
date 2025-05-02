BEGIN;

GRANT SELECT ON TABLE vibetype.event TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.event TO vibetype_account;

ALTER TABLE vibetype.event ENABLE ROW LEVEL SECURITY;

-- Only allow events that are organized by oneself.
CREATE POLICY event_all ON vibetype.event FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);

-- Only display events that are public and not full and not organized by a blocked account.
-- Only display events to which oneself is invited, but not by a guest created by a blocked account.
CREATE POLICY event_select ON vibetype.event FOR SELECT
USING (
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
    id IN (SELECT vibetype_private.events_invited())
  )
);

COMMIT;
