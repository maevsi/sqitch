BEGIN;

GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.device TO maevsi_account;

ALTER TABLE maevsi.device ENABLE ROW LEVEL SECURITY;

CREATE POLICY device_insert ON maevsi.device FOR INSERT WITH CHECK (
  created_by = maevsi.invoker_account_id()
);

CREATE POLICY device_update ON maevsi.device FOR UPDATE USING (
  created_by = maevsi.invoker_account_id()
);

CREATE POLICY device_delete ON maevsi.device FOR DELETE USING (
  created_by = maevsi.invoker_account_id()
);

COMMIT;
