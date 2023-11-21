-- Verify maevsi:database_grafana on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT 1 FROM pg_database WHERE datname='grafana') = 1;
END $$;

ROLLBACK;
