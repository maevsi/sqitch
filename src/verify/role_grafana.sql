BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres_role_service_grafana_username`

SET LOCAL role.service_grafana_username TO :'role_service_grafana_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role(current_setting('role.service_grafana_username'), 'USAGE'));
  -- Other accounts might not exist yet for a NOT-check.
END $$;

ROLLBACK;
