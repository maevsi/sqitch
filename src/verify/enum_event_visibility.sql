BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.event_visibility', 'USAGE'));
END $$;

ROLLBACK;
