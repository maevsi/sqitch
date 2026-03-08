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
  NOT EXISTS (
    WITH _blocked AS MATERIALIZED (SELECT vibetype_private.account_block_ids() AS ids)
    SELECT 1 FROM _blocked, unnest(_blocked.ids) AS b WHERE b = address.created_by
  )
)
WITH CHECK (
  address.created_by = vibetype.invoker_account_id()
);

COMMIT;
