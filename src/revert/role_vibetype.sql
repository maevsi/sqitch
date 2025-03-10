BEGIN;

\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`

DROP OWNED BY :role_vibetype_username;
DROP ROLE :role_vibetype_username;

COMMIT;
