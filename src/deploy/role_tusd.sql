-- Deploy maevsi:role_tusd to pg
-- requires: role_postgraphile

BEGIN;

\set role_maevsi_tusd_password `cat /run/secrets/postgres_role_maevsi-tusd_password`
\set role_maevsi_tusd_username `cat /run/secrets/postgres_role_maevsi-tusd_username`
\set role_maevsi_postgraphile_username `cat /run/secrets/postgres_role_maevsi-postgraphile_username`

CREATE ROLE :role_maevsi_tusd_username LOGIN PASSWORD :'role_maevsi_tusd_password';

GRANT :role_maevsi_tusd_username TO :role_maevsi_postgraphile_username; -- TODO: why postgrahpile?

COMMIT;
