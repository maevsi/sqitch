BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres-role-service-reccoom-username`

DROP ROLE :role_service_reccoom_username;

COMMIT;
