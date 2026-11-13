BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

SELECT 1 / has_function_privilege(:'role_service_vibetype_username', 'vibetype.notification_acknowledge(UUID, BOOLEAN)', 'EXECUTE')::INTEGER;

ROLLBACK;
