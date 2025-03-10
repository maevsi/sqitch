BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.account_interest TO vibetype_account;

ALTER TABLE vibetype.account_interest ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current account.
CREATE POLICY account_interest_select ON vibetype.account_interest FOR SELECT USING (
  account_id = vibetype.invoker_account_id()
);

-- Only allow inserts by the current account.
CREATE POLICY account_interest_insert ON vibetype.account_interest FOR INSERT WITH CHECK (
  account_id = vibetype.invoker_account_id()
);

-- Only allow deletes by the current account.
CREATE POLICY account_interest_delete ON vibetype.account_interest FOR DELETE USING (
  account_id = vibetype.invoker_account_id()
);

COMMIT;
