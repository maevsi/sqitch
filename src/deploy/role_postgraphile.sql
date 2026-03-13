BEGIN;

\set role_service_postgraphile_password `cat /run/secrets/postgres-role-service-postgraphile-password`
\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`

DROP ROLE IF EXISTS :"role_service_postgraphile_username";
CREATE ROLE :"role_service_postgraphile_username" LOGIN PASSWORD :'role_service_postgraphile_password';

COMMIT;
