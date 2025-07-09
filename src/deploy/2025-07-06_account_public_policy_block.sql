BEGIN;

DROP POLICY account_select ON vibetype.account;

CREATE POLICY account_select ON vibetype.account FOR SELECT USING (
  id NOT IN (
    SELECT id FROM vibetype_private.account_block_ids()
  )
);

COMMIT;
