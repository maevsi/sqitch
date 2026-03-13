BEGIN;

\set role_service_vibetype_password `cat /run/secrets/postgres-role-service-vibetype-password`
\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`
\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`

DROP ROLE IF EXISTS :"role_service_vibetype_username";
CREATE ROLE :"role_service_vibetype_username" LOGIN PASSWORD :'role_service_vibetype_password';

GRANT :"role_service_vibetype_username" TO :"role_service_postgraphile_username";

COMMIT;
