BEGIN;

\set role_maevsi_postgraphile_password `cat /run/secrets/postgres_role_maevsi-postgraphile_password`
\set role_maevsi_postgraphile_username `cat /run/secrets/postgres_role_maevsi-postgraphile_username`

DROP ROLE IF EXISTS :role_maevsi_postgraphile_username;
CREATE ROLE :role_maevsi_postgraphile_username LOGIN PASSWORD :'role_maevsi_postgraphile_password';

COMMIT;
