BEGIN;

DROP ROLE IF EXISTS vibetype_account;
CREATE ROLE vibetype_account;

GRANT vibetype_account to vibetype_postgraphile;

COMMIT;
