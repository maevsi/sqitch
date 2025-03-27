BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

DROP OWNED BY :role_service_vibetype_username;
DROP ROLE :role_service_vibetype_username;

COMMIT;
