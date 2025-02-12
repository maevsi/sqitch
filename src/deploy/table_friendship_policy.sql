BEGIN;

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE maevsi.friendship TO maevsi_account;

ALTER TABLE maevsi.friendship ENABLE ROW LEVEL SECURITY;

-- Only show friend records where the current user is involved in a friend relation.
CREATE POLICY friendship_select ON maevsi.friendship FOR SELECT USING (
  ( maevsi.invoker_account_id() = a_account_id
    AND b_account_id NOT IN (SELECT id FROM maevsi_private.account_block_ids())
  )
  OR
  ( maevsi.invoker_account_id() = b_account_id
    AND a_account_id NOT IN (SELECT id FROM maevsi_private.account_block_ids())
  )
);

-- Only allow creation by the current user.
CREATE POLICY friendship_insert ON maevsi.friendship FOR INSERT WITH CHECK (
  created_by = maevsi.invoker_account_id()
);

-- Only allow update by the current user
CREATE POLICY friendship_update ON maevsi.friendship FOR UPDATE
USING (
  ( maevsi.invoker_account_id() = a_account_id
    AND b_account_id NOT IN (SELECT id FROM maevsi_private.account_block_ids())
  )
  OR
  ( maevsi.invoker_account_id() = b_account_id
    AND a_account_id NOT IN (SELECT id FROM maevsi_private.account_block_ids())
  )
)
WITH CHECK (
  updated_by = maevsi.invoker_account_id()
);

CREATE POLICY friendship_delete ON maevsi.friendship FOR DELETE
USING (
  ( maevsi.invoker_account_id() = a_account_id
    AND b_account_id NOT IN (SELECT id FROM maevsi_private.account_block_ids())
  )
  OR
  ( maevsi.invoker_account_id() = b_account_id
    AND a_account_id NOT IN (SELECT id FROM maevsi_private.account_block_ids())
  )
);

COMMIT;
