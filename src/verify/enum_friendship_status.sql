BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.friendship_status', 'USAGE'));
END $$;

ROLLBACK;
