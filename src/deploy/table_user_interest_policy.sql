-- Deploy maevsi:table_user_interest_policy to pg

BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.user_interest TO maevsi_account;

ALTER TABLE maevsi.user_interest ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current user.
CREATE POLICY user_interest_select ON maevsi.user_interest FOR SELECT USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  user_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow inserts by the current user.
CREATE POLICY user_interest_insert ON maevsi.user_interest FOR INSERT WITH CHECK (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  user_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow deletes by the current user.
CREATE POLICY user_interest_delete ON maevsi.user_interest FOR DELETE USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  user_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

COMMIT;
