BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres_role_service_reccoom_username`

DROP ROLE :role_service_reccoom_username;

COMMIT;
