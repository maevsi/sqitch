BEGIN;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.friendship TO vibetype_account;

ALTER TABLE vibetype.friendship ENABLE ROW LEVEL SECURITY;

-- Only allow interactions with friendships in which the current user is involved.
CREATE POLICY friendship_existing ON vibetype.friendship FOR ALL USING (
  (
    vibetype.invoker_account_id() = a_account_id
    AND b_account_id NOT IN (SELECT id FROM vibetype_private.account_block_ids())
  )
  OR
  (
    vibetype.invoker_account_id() = b_account_id
    AND a_account_id NOT IN (SELECT id FROM vibetype_private.account_block_ids())
  )
)
WITH CHECK (FALSE);

-- Only allow creation by the current user.
CREATE POLICY friendship_insert ON vibetype.friendship FOR INSERT WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

-- Only allow update by the current user and only the state transition requested -> accepted.
CREATE POLICY friendship_update ON vibetype.friendship FOR UPDATE USING (
  status = 'requested'::vibetype.friendship_status
) WITH CHECK (
  status = 'accepted'::vibetype.friendship_status
  AND
  updated_by = vibetype.invoker_account_id()
);

COMMIT;
