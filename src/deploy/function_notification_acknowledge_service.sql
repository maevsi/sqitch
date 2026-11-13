BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

GRANT EXECUTE ON FUNCTION vibetype.notification_acknowledge(UUID, BOOLEAN) TO :role_service_vibetype_username;

COMMIT;
