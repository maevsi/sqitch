BEGIN;

GRANT INSERT, SELECT ON TABLE maevsi.report TO maevsi_account;

ALTER TABLE maevsi.report ENABLE ROW LEVEL SECURITY;

-- Only allow inserts for reports authored by the current user.
CREATE POLICY report_insert ON maevsi.report FOR INSERT WITH CHECK (
  maevsi.account_id() IS NOT NULL
  AND
  author_account_id = maevsi.account_id()
);

-- Only allow selects for reports authored by the current user.
CREATE POLICY report_select ON maevsi.report FOR SELECT USING (
  maevsi.account_id() IS NOT NULL
  AND
  author_account_id = maevsi.account_id()
);

COMMIT;
