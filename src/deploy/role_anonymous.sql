BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres_role_service_postgraphile_username`

DROP ROLE IF EXISTS vibetype_anonymous;
CREATE ROLE vibetype_anonymous;

GRANT vibetype_anonymous to :role_service_postgraphile_username;

COMMIT;
