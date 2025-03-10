BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.jwt', 'USAGE'));
END $$;

ROLLBACK;
