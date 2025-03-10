BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.event_size', 'USAGE'));
END $$;

ROLLBACK;
