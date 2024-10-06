-- Deploy maevsi:role_stomper to pg
-- requires: role_postgraphile

BEGIN;

\set role_maevsi_stomper_password `cat /run/secrets/postgres_role_maevsi-stomper_password`
\set role_maevsi_stomper_username `cat /run/secrets/postgres_role_maevsi-stomper_username`
\set role_maevsi_postgraphile_username `cat /run/secrets/postgres_role_maevsi-postgraphile_username`

CREATE ROLE :role_maevsi_stomper_username LOGIN PASSWORD :'role_maevsi_stomper_password';

GRANT :role_maevsi_stomper_username TO :role_maevsi_postgraphile_username; -- TODO: why postgrahpile?

COMMIT;
