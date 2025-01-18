BEGIN;

GRANT INSERT, SELECT ON TABLE maevsi.account_block TO maevsi_account;
GRANT SELECT ON TABLE maevsi.account_block TO maevsi_anonymous;

ALTER TABLE maevsi.account_block ENABLE ROW LEVEL SECURITY;

-- Only allow account blocking creation authored by the current user.
CREATE POLICY account_block_insert ON maevsi.account_block FOR INSERT WITH CHECK (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  author_account_id = maevsi.invoker_account_id()
);

-- Only show account blockings which are created by the current user or which affect the current user.
CREATE POLICY account_block_select ON maevsi.account_block FOR SELECT USING (
  author_account_id = maevsi.invoker_account_id()
  OR
  blocked_account_id = maevsi.invoker_account_id()
);

COMMIT;
