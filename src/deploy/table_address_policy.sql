BEGIN;

GRANT SELECT ON TABLE vibetype.address TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.address TO vibetype_account;

ALTER TABLE vibetype.address ENABLE ROW LEVEL SECURITY;

CREATE POLICY address ON vibetype.address USING (
  created_by = vibetype.invoker_account_id()
  AND
  created_by NOT IN (
    SELECT id FROM vibetype_private.account_block_ids()
  )
) WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
