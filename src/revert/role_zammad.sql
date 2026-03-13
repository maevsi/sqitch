BEGIN;

\set role_service_zammad_username `cat /run/secrets/postgres-role-service-zammad-username`

DROP ROLE :"role_service_zammad_username";

COMMIT;
