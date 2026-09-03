BEGIN;

\set role_service_vibetype_password `cat /run/secrets/postgres-role-service-vibetype-password`
\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`
\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`

SET LOCAL role.service_vibetype_password TO :'role_service_vibetype_password';
SET LOCAL role.service_vibetype_username TO :'role_service_vibetype_username';

DO $$
DECLARE
  _username text := current_setting('role.service_vibetype_username');
  _options text := format('LOGIN PASSWORD %L', current_setting('role.service_vibetype_password'));
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = _username) THEN
    EXECUTE format('ALTER ROLE %I %s', _username, _options);
  ELSE
    EXECUTE format('CREATE ROLE %I %s', _username, _options);
  END IF;
END $$;

GRANT :role_service_vibetype_username TO :role_service_postgraphile_username;

COMMIT;
