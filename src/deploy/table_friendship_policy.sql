BEGIN;

GRANT INSERT, UPDATE, SELECT ON TABLE maevsi.friendship TO maevsi_account;

ALTER TABLE maevsi.friendship ENABLE ROW LEVEL SECURITY;

-- Only show friend records where the current user is involved in a friend relation.
CREATE POLICY friendship_select ON maevsi.friendship FOR SELECT USING (
  maevsi.invoker_account_id() in (SELECT id FROM maevsi.friendship_account_ids())
);

-- Only allow creation by the current user who is one side of the friend relation.
-- A newly created friend relation is a friend request.
CREATE POLICY friendship_insert ON maevsi.friendship FOR INSERT WITH CHECK (
  created_by = maevsi.invoker_account_id()
  and (created_by = a_account_id or created_by = b_account_id)
  and status = 'pending'::maevsi.friendship_status
);

-- Only allow update by the current user who is one side of the friend relation
-- but not the one who created the friend request
CREATE POLICY friendship_update ON maevsi.friendship FOR INSERT WITH CHECK (
  updated_by = maevsi.invoker_account_id()
  and (updated_by = a_account_id or updated_by = b_account_id)
  and updated_by <> created_by
);

COMMIT;
