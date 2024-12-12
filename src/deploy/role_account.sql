BEGIN;

CREATE ROLE maevsi_account;

GRANT maevsi_account to maevsi_postgraphile;

COMMIT;
