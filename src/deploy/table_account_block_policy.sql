BEGIN;

GRANT INSERT, SELECT ON TABLE vibetype.account_block TO vibetype_account;
GRANT SELECT ON TABLE vibetype.account_block TO vibetype_anonymous;

ALTER TABLE vibetype.account_block ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current account.
CREATE POLICY account_block_select ON vibetype.account_block FOR SELECT USING (
  created_by = vibetype.invoker_account_id()
);

-- Only allow inserts by the current account.
CREATE POLICY account_block_insert ON vibetype.account_block FOR INSERT WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

-- Only allow deletes by the current account.
CREATE POLICY account_block_delete ON vibetype.account_block FOR DELETE USING (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
