BEGIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE maevsi.device TO maevsi_account;

ALTER TABLE maevsi.device ENABLE ROW LEVEL SECURITY;

CREATE POLICY device_new ON maevsi.device WITH CHECK (
  TRUE
);

CREATE POLICY device_existing ON maevsi.device USING (
  created_by = maevsi.invoker_account_id()
);

COMMIT;
