BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.achievement_type', 'USAGE'));
END $$;

ROLLBACK;
