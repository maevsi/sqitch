BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

DROP ROLE :"role_service_vibetype_username";

COMMIT;
