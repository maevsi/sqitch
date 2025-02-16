BEGIN;

\set role_maevsi_username `cat /run/secrets/postgres_role_maevsi_username`

DROP OWNED BY :role_maevsi_username;
DROP ROLE :role_maevsi_username;

COMMIT;
