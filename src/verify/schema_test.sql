BEGIN;

DO $$
BEGIN
  ASSERT EXISTS(SELECT * FROM pg_catalog.pg_namespace WHERE nspname = 'maevsi_test');
END $$;

ROLLBACK;
