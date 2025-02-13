BEGIN;

\set role_maevsi_tusd_username `cat /run/secrets/postgres_role_maevsi-tusd_username`

DROP OWNED BY :role_maevsi_tusd_username;
DROP ROLE :role_maevsi_tusd_username;

COMMIT;
