BEGIN;

\set role_maevsi_postgraphile_username `cat /run/secrets/postgres_role_maevsi-postgraphile_username`

DROP ROLE IF EXISTS maevsi_anonymous;
CREATE ROLE maevsi_anonymous;

GRANT maevsi_anonymous to :role_maevsi_postgraphile_username;

COMMIT;
