BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`

DROP ROLE IF EXISTS vibetype_account;
CREATE ROLE vibetype_account;

GRANT vibetype_account to :"role_service_postgraphile_username";

COMMIT;
