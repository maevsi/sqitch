-- Deploy maevsi:table_account_social_link_policy to pg

BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.account_social_link TO maevsi_account;

-- Only allow selects for social links of the current account.
CREATE POLICY account_social_link_select ON maevsi.account_social_link FOR SELECT USING (
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow inserting social links of the current account.
CREATE POLICY account_social_link_insert ON maevsi.account_social_link FOR INSERT WITH CHECK (
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow deleting social links of the current account..
CREATE POLICY account_social_link_delete ON maevsi.account_social_link FOR DELETE USING (
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

COMMIT;
