BEGIN;

GRANT INSERT, SELECT ON TABLE maevsi.report TO maevsi_account;

ALTER TABLE maevsi.report ENABLE ROW LEVEL SECURITY;

-- Only allow inserts for reports authored by the current user.
CREATE POLICY report_insert ON maevsi.report FOR INSERT WITH CHECK (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow selects for reports authored by the current user.
CREATE POLICY report_select ON maevsi.report FOR SELECT USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

COMMIT;
