BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

REVOKE USAGE ON SCHEMA vibetype_private FROM :role_service_vibetype_username;

DROP TABLE vibetype_private.email_address;
DROP TYPE vibetype_private.email_status;

COMMIT;
