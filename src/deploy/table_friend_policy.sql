BEGIN;

GRANT INSERT, UPDATE, SELECT ON TABLE maevsi.friend TO maevsi_account;

ALTER TABLE maevsi.friend ENABLE ROW LEVEL SECURITY;

-- Only show friend records where ithe current user is involved in a friend relation.
CREATE POLICY friend_select ON maevsi.friend FOR SELECT USING (
  maevsi.invoker_account_id() in (SELECT id FROM maevsi.friend_ids())
);

-- Only allow creation by the current user who is one side of the friend relation.
-- A newly created friend relation is a friend request.
CREATE POLICY friend_insert ON maevsi.friend FOR INSERT WITH CHECK (
  created_by = maevsi.invoker_account_id()
  and (created_by = a_account_id or created_by = b_account_id)
  and status = 'pending'::maevsi.friend_status
);

-- Only allow update by the current user who is one side of the friend relation
-- but not the one who created the friend request
CREATE POLICY friend_update ON maevsi.friend FOR INSERT WITH CHECK (
  updated_by = maevsi.invoker_account_id()
  and (updated_by = a_account_id or updated_by = b_account_id)
  and updated_by <> created_by
);

COMMIT;
