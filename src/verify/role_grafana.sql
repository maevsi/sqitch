-- Verify maevsi:role_grafana on pg

\connect grafana

BEGIN;

\set role_grafana_username `cat /run/secrets/postgres_role_grafana_username`

SET LOCAL sqitch.role_grafana_username TO :'role_grafana_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role(current_setting('sqitch.role_grafana_username'), 'USAGE'));
  -- Other accounts might not exist yet for a NOT-check.
END $$;

ROLLBACK;
