BEGIN;

GRANT SELECT ON TABLE maevsi.address TO maevsi_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE maevsi.address TO maevsi_account;

ALTER TABLE maevsi.address ENABLE ROW LEVEL SECURITY;

CREATE POLICY address ON maevsi.address USING (
  created_by = maevsi.invoker_account_id()
  AND
  created_by NOT IN (
    SELECT id FROM maevsi_private.account_block_ids()
  )
) WITH CHECK (
  created_by = maevsi.invoker_account_id()
);

COMMIT;
