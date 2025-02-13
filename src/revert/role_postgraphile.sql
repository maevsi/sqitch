BEGIN;

\set role_maevsi_postgraphile_username `cat /run/secrets/postgres_role_maevsi-postgraphile_username`

DROP OWNED BY :role_maevsi_postgraphile_username;
DROP ROLE :role_maevsi_postgraphile_username;

COMMIT;
