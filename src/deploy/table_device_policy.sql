BEGIN;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.device TO vibetype_account;

ALTER TABLE vibetype.device ENABLE ROW LEVEL SECURITY;

CREATE POLICY device ON vibetype.device USING (
  created_by = vibetype.invoker_account_id()
)
WITH CHECK (TRUE);

COMMIT;
