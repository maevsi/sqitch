BEGIN;

DROP POLICY account_select ON vibetype.account;
DROP POLICY account_update ON vibetype.account;

DROP TABLE vibetype.account;

COMMIT;
