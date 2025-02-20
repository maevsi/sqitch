BEGIN;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE maevsi.device TO maevsi_account;

ALTER TABLE maevsi.device ENABLE ROW LEVEL SECURITY;

CREATE POLICY device ON maevsi.device USING (
  created_by = maevsi.invoker_account_id()
)
WITH CHECK (TRUE);

COMMIT;
