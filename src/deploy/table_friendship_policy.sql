BEGIN;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE maevsi.friendship TO maevsi_account;

ALTER TABLE maevsi.friendship ENABLE ROW LEVEL SECURITY;

-- Only allow interactions with friendships in which the current user is involved.
CREATE POLICY friendship_existing ON maevsi.friendship USING (
  (
    maevsi.invoker_account_id() = a_account_id
    AND b_account_id NOT IN (SELECT id FROM maevsi_private.account_block_ids())
  )
  OR
  (
    maevsi.invoker_account_id() = b_account_id
    AND a_account_id NOT IN (SELECT id FROM maevsi_private.account_block_ids())
  )
)
WITH CHECK (FALSE);

-- Only allow creation by the current user.
CREATE POLICY friendship_insert ON maevsi.friendship FOR INSERT WITH CHECK (
  created_by = maevsi.invoker_account_id()
);

-- Only allow update by the current user.
CREATE POLICY friendship_update ON maevsi.friendship FOR UPDATE WITH CHECK (
  updated_by = maevsi.invoker_account_id()
);

COMMIT;
