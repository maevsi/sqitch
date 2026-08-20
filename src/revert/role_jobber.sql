BEGIN;

\set role_service_jobber_username `cat /run/secrets/postgres-role-service-jobber-username`

REVOKE DELETE ON TABLE vibetype_private.outbox FROM :role_service_jobber_username;
DROP ROLE :role_service_jobber_username;

COMMIT;
