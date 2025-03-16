BEGIN;

\set role_service_postgraphile_password `cat /run/secrets/postgres_role_service_postgraphile_password`
\set role_service_postgraphile_username `cat /run/secrets/postgres_role_service_postgraphile_username`

DROP ROLE IF EXISTS :role_service_postgraphile_username;
CREATE ROLE :role_service_postgraphile_username LOGIN PASSWORD :'role_service_postgraphile_password';

COMMIT;
