BEGIN;

\set role_postgraphile_username `cat /run/secrets/postgres_role_postgraphile_username`

DROP ROLE IF EXISTS vibetype_account;
CREATE ROLE vibetype_account;

GRANT vibetype_account to :role_postgraphile_username;

COMMIT;
