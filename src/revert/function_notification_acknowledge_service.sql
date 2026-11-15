BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

REVOKE EXECUTE ON FUNCTION vibetype.notification_acknowledge(UUID, BOOLEAN) FROM :role_service_vibetype_username;

COMMIT;
