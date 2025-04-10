BEGIN;

DROP POLICY account_select ON vibetype.account;

DROP TABLE vibetype.account;

COMMIT;
