BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.session', 'USAGE'));
END $$;

ROLLBACK;
