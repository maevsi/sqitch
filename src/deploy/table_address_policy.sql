BEGIN;

GRANT SELECT ON TABLE vibetype.address TO vibetype_account, vibetype_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE vibetype.address TO vibetype_account;

ALTER TABLE vibetype.address ENABLE ROW LEVEL SECURITY;

-- Only allow selects for addresses created by the invoker's account.
-- Disallow selects for addresses created by a blocked account.
CREATE POLICY address_select ON vibetype.address FOR SELECT USING (
  created_by = vibetype.invoker_account_id()
  AND
  created_by NOT IN (
    SELECT id FROM vibetype_private.account_block_ids()
  )
);

-- Only allow inserts for addresses created by the invoker's account.
CREATE POLICY address_insert ON vibetype.address FOR INSERT WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

-- Only allow updates for addresses created by the invoker's account.
CREATE POLICY address_update ON vibetype.address FOR UPDATE USING (
  created_by = vibetype.invoker_account_id()
);

-- Only allow deletes for addresses created by the invoker's account.
CREATE POLICY address_delete ON vibetype.address FOR DELETE USING (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
