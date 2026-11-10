BEGIN;

\set role_service_postgraphile_password `cat /run/secrets/postgres-role-service-postgraphile-password`
\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`

SET LOCAL role.service_postgraphile_password TO :'role_service_postgraphile_password';
SET LOCAL role.service_postgraphile_username TO :'role_service_postgraphile_username';

DO $$
DECLARE
  _username text := current_setting('role.service_postgraphile_username');
  _options text := format('LOGIN PASSWORD %L', current_setting('role.service_postgraphile_password'));
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = _username) THEN
    EXECUTE format('ALTER ROLE %I %s', _username, _options);
  ELSE
    EXECUTE format('CREATE ROLE %I %s', _username, _options);
  END IF;
END $$;

COMMIT;
