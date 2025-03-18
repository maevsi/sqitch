BEGIN;

GRANT INSERT, SELECT ON TABLE vibetype.account_block TO vibetype_account;
GRANT SELECT ON TABLE vibetype.account_block TO vibetype_anonymous;

ALTER TABLE vibetype.account_block ENABLE ROW LEVEL SECURITY;

-- Only allow account blocking creation with accurate creator.
CREATE POLICY account_block_insert ON vibetype.account_block FOR INSERT WITH CHECK (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  created_by = vibetype.invoker_account_id()
);

-- Only show account blockings which are created by the current user or which affect the current user.
CREATE POLICY account_block_select ON vibetype.account_block FOR SELECT USING (
  created_by = vibetype.invoker_account_id()
  OR
  blocked_account_id = vibetype.invoker_account_id()
);

COMMIT;
