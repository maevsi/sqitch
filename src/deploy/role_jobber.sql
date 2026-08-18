BEGIN;

\set role_service_jobber_password `cat /run/secrets/postgres-role-service-jobber-password`
\set role_service_jobber_username `cat /run/secrets/postgres-role-service-jobber-username`

DROP ROLE IF EXISTS :role_service_jobber_username;
CREATE ROLE :role_service_jobber_username LOGIN PASSWORD :'role_service_jobber_password';

-- Minimal privilege for the scheduled OutboxPurge job (`stack`'s jobber service): only allowed to
-- delete expired rows from the outbox, nothing else.
GRANT DELETE ON TABLE vibetype_private.outbox TO :role_service_jobber_username;

COMMIT;
