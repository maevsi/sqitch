BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`

DROP ROLE :"role_service_postgraphile_username";

COMMIT;
