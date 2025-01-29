BEGIN;

GRANT SELECT ON TABLE maevsi.address TO maevsi_account, maevsi_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.address TO maevsi_account;

ALTER TABLE maevsi.address ENABLE ROW LEVEL SECURITY;

-- Only allow selects for addresses created by the invoker's account.
-- Disallow selects for addresses created by a blocked account.
CREATE POLICY address_select ON maevsi.address FOR SELECT USING (
  created_by = maevsi.invoker_account_id()
  AND
  created_by NOT IN (
    SELECT id FROM maevsi_private.account_block_ids()
  )
);

-- Only allow inserts for addresses created by the invoker's account.
CREATE POLICY address_insert ON maevsi.address FOR INSERT WITH CHECK (
  created_by = maevsi.invoker_account_id()
);

-- Only allow updates for addresses created by the invoker's account.
CREATE POLICY address_update ON maevsi.address FOR UPDATE USING (
  created_by = maevsi.invoker_account_id()
);

-- Only allow deletes for addresses created by the invoker's account.
CREATE POLICY address_delete ON maevsi.address FOR DELETE USING (
  created_by = maevsi.invoker_account_id()
);

COMMIT;
