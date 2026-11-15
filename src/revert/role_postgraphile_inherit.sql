BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`
\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

GRANT :role_service_vibetype_username TO :role_service_postgraphile_username WITH INHERIT TRUE, SET TRUE;

COMMIT;
