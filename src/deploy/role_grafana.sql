BEGIN;

\set role_service_grafana_password `cat /run/secrets/postgres-role-service-grafana-password`
\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`

SET LOCAL role.service_grafana_password TO :'role_service_grafana_password';
SET LOCAL role.service_grafana_username TO :'role_service_grafana_username';

DO $$
DECLARE
  _username text := current_setting('role.service_grafana_username');
  _options text := format('LOGIN PASSWORD %L', current_setting('role.service_grafana_password'));
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = _username) THEN
    EXECUTE format('ALTER ROLE %I %s', _username, _options);
  ELSE
    EXECUTE format('CREATE ROLE %I %s', _username, _options);
  END IF;
END $$;

COMMIT;
