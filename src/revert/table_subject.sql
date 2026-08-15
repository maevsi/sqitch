BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

REVOKE SELECT ON TABLE vibetype_private.subject FROM :role_service_vibetype_username;

DROP TABLE vibetype_private.subject;

COMMIT;
