BEGIN;

GRANT INSERT, SELECT ON TABLE maevsi.report TO maevsi_account;

ALTER TABLE maevsi.report ENABLE ROW LEVEL SECURITY;

-- Only allow inserts for reports authored by the current user.
CREATE POLICY report_insert ON maevsi.report FOR INSERT WITH CHECK (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  author_account_id = maevsi.invoker_account_id()
);

-- Only allow selects for reports authored by the current user.
CREATE POLICY report_select ON maevsi.report FOR SELECT USING (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  author_account_id = maevsi.invoker_account_id()
);

COMMIT;
