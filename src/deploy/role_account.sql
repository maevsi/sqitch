BEGIN;

DROP ROLE IF EXISTS maevsi_account;
CREATE ROLE maevsi_account;

GRANT maevsi_account to maevsi_postgraphile;

COMMIT;
