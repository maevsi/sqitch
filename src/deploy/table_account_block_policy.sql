-- Deploy maevsi:table_account_block_policy to pg
-- requires: schema_public
-- requires: table_account_block
-- requires: role_account

BEGIN;

GRANT INSERT, SELECT ON TABLE maevsi.account_block TO maevsi_account;

ALTER TABLE maevsi.account_block ENABLE ROW LEVEL SECURITY;

-- Only allow inserts for blocked accounts authored by the current user.
CREATE POLICY account_block_insert ON maevsi.account_block FOR INSERT WITH CHECK (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow selects for blocked accounts authored by the current user.
CREATE POLICY account_block_select ON maevsi.account_block FOR SELECT USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

COMMIT;
