BEGIN;

\set role_vibetype_password `cat /run/secrets/postgres_role_vibetype_password`
\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`
\set role_postgraphile_username `cat /run/secrets/postgres_role_postgraphile_username`

DROP ROLE IF EXISTS :role_vibetype_username;
CREATE ROLE :role_vibetype_username LOGIN PASSWORD :'role_vibetype_password';

GRANT :role_vibetype_username TO :role_postgraphile_username;

COMMIT;
