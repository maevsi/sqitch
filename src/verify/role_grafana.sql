-- Verify maevsi:role_grafana on pg

\connect grafana

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role('grafana', 'USAGE'));
  -- Other accounts might not exist yet for a NOT-check.
END $$;

ROLLBACK;
