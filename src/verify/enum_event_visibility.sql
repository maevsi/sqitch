BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.event_visibility', 'USAGE'));
END $$;

ROLLBACK;
