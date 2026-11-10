BEGIN;

GRANT SELECT ON TABLE vibetype.address TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.address TO vibetype_account;

ALTER TABLE vibetype.address ENABLE ROW LEVEL SECURITY;

CREATE POLICY address_all ON vibetype.address FOR ALL
USING (
  (
    address.created_by = vibetype.invoker_account_id()
    OR EXISTS (
      SELECT 1
      FROM vibetype.event e
      WHERE e.address_id = address.id
    )
  )
  AND
  NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = address.created_by)
)
WITH CHECK (
  address.created_by = vibetype.invoker_account_id()
);

-- Addresses of accessible events stay readable through `address_all`, but only their creator may modify them.
CREATE POLICY address_update_creator ON vibetype.address AS RESTRICTIVE FOR UPDATE
USING (
  address.created_by = vibetype.invoker_account_id()
);

CREATE POLICY address_delete_creator ON vibetype.address AS RESTRICTIVE FOR DELETE
USING (
  address.created_by = vibetype.invoker_account_id()
);

COMMIT;
