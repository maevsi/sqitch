BEGIN;

\set role_service_zammad_username `cat /run/secrets/postgres_role_service_zammad_username`

DROP ROLE :role_service_zammad_username;

COMMIT;
