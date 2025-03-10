BEGIN;

\set role_vibetype_postgraphile_password `cat /run/secrets/postgres_role_postgraphile_password`
\set role_postgraphile_username `cat /run/secrets/postgres_role_postgraphile_username`

DROP ROLE IF EXISTS :role_postgraphile_username;
CREATE ROLE :role_postgraphile_username LOGIN PASSWORD :'role_vibetype_postgraphile_password';

COMMIT;
