BEGIN;

GRANT INSERT, SELECT ON TABLE maevsi.account_block TO maevsi_account;
GRANT SELECT ON TABLE maevsi.account_block TO maevsi_anonymous;

ALTER TABLE maevsi.account_block ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current account.
CREATE POLICY account_block_select ON maevsi.account_block FOR SELECT USING (
  created_by = maevsi.invoker_account_id()
);

-- Only allow inserts by the current account.
CREATE POLICY account_block_insert ON maevsi.account_block FOR INSERT WITH CHECK (
  created_by = maevsi.invoker_account_id()
);

-- Only allow deletes by the current account.
CREATE POLICY account_block_delete ON maevsi.account_block FOR DELETE USING (
  created_by = maevsi.invoker_account_id()
);

COMMIT;
