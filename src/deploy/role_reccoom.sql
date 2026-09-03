BEGIN;

\set role_service_reccoom_password `cat /run/secrets/postgres-role-service-reccoom-password`
\set role_service_reccoom_username `cat /run/secrets/postgres-role-service-reccoom-username`

SET LOCAL role.service_reccoom_password TO :'role_service_reccoom_password';
SET LOCAL role.service_reccoom_username TO :'role_service_reccoom_username';

DO $$
DECLARE
  _username text := current_setting('role.service_reccoom_username');
  _options text := format('LOGIN PASSWORD %L BYPASSRLS', current_setting('role.service_reccoom_password'));
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = _username) THEN
    EXECUTE format('ALTER ROLE %I %s', _username, _options);
  ELSE
    EXECUTE format('CREATE ROLE %I %s', _username, _options);
  END IF;
END $$;

COMMIT;
