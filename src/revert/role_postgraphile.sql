BEGIN;

\set role_postgraphile_username `cat /run/secrets/postgres_role_postgraphile_username`

DROP OWNED BY :role_postgraphile_username;
DROP ROLE :role_postgraphile_username;

COMMIT;
