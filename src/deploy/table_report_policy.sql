BEGIN;

GRANT INSERT, SELECT ON TABLE vibetype.report TO vibetype_account;

ALTER TABLE vibetype.report ENABLE ROW LEVEL SECURITY;

-- Only allow inserts for reports created by the current user.
CREATE POLICY report_insert ON vibetype.report FOR INSERT WITH CHECK (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  created_by = vibetype.invoker_account_id()
);

-- Only allow selects for reports created by the current user.
CREATE POLICY report_select ON vibetype.report FOR SELECT USING (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  created_by = vibetype.invoker_account_id()
);

COMMIT;
