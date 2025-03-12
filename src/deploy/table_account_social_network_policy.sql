BEGIN;

GRANT SELECT ON TABLE vibetype.account_social_network TO vibetype_anonymous;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE vibetype.account_social_network TO vibetype_account;

ALTER TABLE vibetype.account_social_network ENABLE ROW LEVEL SECURITY;

-- Only allow inserting social links of the current account.
CREATE POLICY account_social_network_insert ON vibetype.account_social_network FOR INSERT WITH CHECK (
  account_id = vibetype.invoker_account_id()
);

-- Only allow updating social links of the current account.
CREATE POLICY account_social_network_update ON vibetype.account_social_network FOR UPDATE USING (
  account_id = vibetype.invoker_account_id()
);

-- Only allow deleting social links of the current account..
CREATE POLICY account_social_network_delete ON vibetype.account_social_network FOR DELETE USING (
  account_id = vibetype.invoker_account_id()
);

COMMIT;
