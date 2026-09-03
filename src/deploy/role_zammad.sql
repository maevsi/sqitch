BEGIN;

\set role_service_zammad_password `cat /run/secrets/postgres-role-service-zammad-password`
\set role_service_zammad_username `cat /run/secrets/postgres-role-service-zammad-username`

SET LOCAL role.service_zammad_password TO :'role_service_zammad_password';
SET LOCAL role.service_zammad_username TO :'role_service_zammad_username';

DO $$
DECLARE
  _username text := current_setting('role.service_zammad_username');
  _options text := format('LOGIN PASSWORD %L', current_setting('role.service_zammad_password'));
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = _username) THEN
    EXECUTE format('ALTER ROLE %I %s', _username, _options);
  ELSE
    EXECUTE format('CREATE ROLE %I %s', _username, _options);
  END IF;
END $$;

COMMIT;
