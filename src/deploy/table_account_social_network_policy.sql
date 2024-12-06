-- Deploy maevsi:table_account_social_network_policy to pg

BEGIN;

GRANT SELECT ON TABLE maevsi.account_social_network TO maevsi_anonymous;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE maevsi.account_social_network TO maevsi_account;

-- Only allow inserting social links of the current account.
CREATE POLICY account_social_network_insert ON maevsi.account_social_network FOR INSERT WITH CHECK (
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow updating social links of the current account.
CREATE POLICY account_social_network_update ON maevsi.account_social_network FOR UPDATE USING (
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow deleting social links of the current account..
CREATE POLICY account_social_network_delete ON maevsi.account_social_network FOR DELETE USING (
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

COMMIT;
