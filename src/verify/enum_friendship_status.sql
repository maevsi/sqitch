BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.friendship_status', 'USAGE'));
END $$;

ROLLBACK;
