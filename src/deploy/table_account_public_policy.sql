BEGIN;

GRANT SELECT ON TABLE vibetype.account TO vibetype_account, vibetype_anonymous;
GRANT UPDATE ON TABLE vibetype.account TO vibetype_account;

ALTER TABLE vibetype.account ENABLE ROW LEVEL SECURITY;

-- Make all accounts accessible by everyone.
CREATE POLICY account_select ON vibetype.account FOR SELECT
USING (
  id NOT IN (
    SELECT id FROM vibetype_private.account_block_ids()
  )
);

CREATE POLICY account_update ON vibetype.account FOR UPDATE
USING (
  id = vibetype.invoker_account_id()
);

COMMIT;
