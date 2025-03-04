BEGIN;

\set role_maevsi_password `cat /run/secrets/postgres_role_maevsi_password`
\set role_maevsi_username `cat /run/secrets/postgres_role_maevsi_username`
\set role_maevsi_postgraphile_username `cat /run/secrets/postgres_role_maevsi-postgraphile_username`

DROP ROLE IF EXISTS :role_maevsi_username;
CREATE ROLE :role_maevsi_username LOGIN PASSWORD :'role_maevsi_password';

GRANT :role_maevsi_username TO :role_maevsi_postgraphile_username;

COMMIT;
