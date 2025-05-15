BEGIN;

GRANT SELECT ON TABLE vibetype.address TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.address TO vibetype_account;

ALTER TABLE vibetype.address ENABLE ROW LEVEL SECURITY;

CREATE POLICY address_all ON vibetype.address FOR ALL
USING (
  (
    created_by = vibetype.invoker_account_id()
    OR
    id IN (SELECT address_id FROM vibetype_private.event_policy_select())
  )
  AND
  created_by NOT IN (
    SELECT id FROM vibetype_private.account_block_ids()
  )
)
WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
