BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres_role_service_postgraphile_username`

DROP ROLE :role_service_postgraphile_username;

COMMIT;
