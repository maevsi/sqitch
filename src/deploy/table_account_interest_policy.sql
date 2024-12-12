BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.account_interest TO maevsi_account;

ALTER TABLE maevsi.account_interest ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current account.
CREATE POLICY account_interest_select ON maevsi.account_interest FOR SELECT USING (
  account_id = maevsi.account_id()
);

-- Only allow inserts by the current account.
CREATE POLICY account_interest_insert ON maevsi.account_interest FOR INSERT WITH CHECK (
  account_id = maevsi.account_id()
);

-- Only allow deletes by the current account.
CREATE POLICY account_interest_delete ON maevsi.account_interest FOR DELETE USING (
  account_id = maevsi.account_id()
);

COMMIT;
