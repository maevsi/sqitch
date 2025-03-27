BEGIN;

\set role_service_vibetype_password `cat /run/secrets/postgres_role_service_vibetype_password`
\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`
\set role_service_postgraphile_username `cat /run/secrets/postgres_role_service_postgraphile_username`

DROP ROLE IF EXISTS :role_service_vibetype_username;
CREATE ROLE :role_service_vibetype_username LOGIN PASSWORD :'role_service_vibetype_password';

GRANT :role_service_vibetype_username TO :role_service_postgraphile_username;

COMMIT;
