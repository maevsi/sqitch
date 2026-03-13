BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`

DROP ROLE IF EXISTS vibetype_anonymous;
CREATE ROLE vibetype_anonymous;

GRANT vibetype_anonymous to :"role_service_postgraphile_username";

COMMIT;
