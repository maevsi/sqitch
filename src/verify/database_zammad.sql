BEGIN;

DO $$
BEGIN
  ASSERT (SELECT 1 FROM pg_database WHERE datname='zammad') = 1;
END $$;

ROLLBACK;
