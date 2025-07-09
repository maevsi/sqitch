BEGIN;

DROP POLICY account_select ON vibetype.account;

CREATE POLICY account_select ON vibetype.account FOR SELECT USING (
  TRUE
);

COMMIT;
