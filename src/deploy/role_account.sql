BEGIN;

\set role_maevsi_postgraphile_username `cat /run/secrets/postgres_role_maevsi-postgraphile_username`

DROP ROLE IF EXISTS maevsi_account;
CREATE ROLE maevsi_account;

GRANT maevsi_account to :role_maevsi_postgraphile_username;

COMMIT;
