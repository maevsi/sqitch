BEGIN;

GRANT SELECT ON TABLE vibetype.event_category_mapping TO vibetype_anonymous;
GRANT SELECT, INSERT, DELETE ON TABLE vibetype.event_category_mapping TO vibetype_account;

ALTER TABLE vibetype.event_category_mapping ENABLE ROW LEVEL SECURITY;

-- Allow selects for events created by the current user.
-- Allow events that are public or that the user is invited to, but exclude events
-- created by a blocked user and events created by a user who blocked the current user.
CREATE POLICY event_category_mapping_select ON vibetype.event_category_mapping FOR SELECT USING (
  (
    vibetype.invoker_account_id() IS NOT NULL
    AND (
      (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
    )
  )
  OR
      event_id IN (SELECT vibetype_private.events_invited())
  OR (
    (SELECT visibility FROM vibetype.event WHERE id = event_id) = 'public'
    AND (SELECT created_by FROM vibetype.event WHERE id = event_id) NOT IN (
      SELECT id FROM vibetype_private.account_block_ids()
    )
  )
);

-- Only allow inserts for events created by user.
CREATE POLICY event_category_mapping_insert ON vibetype.event_category_mapping FOR INSERT WITH CHECK (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);

-- Only allow deletes for events created by user.
CREATE POLICY event_category_mapping_delete ON vibetype.event_category_mapping FOR DELETE USING (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);

COMMIT;
