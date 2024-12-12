BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.event_unlock_response', 'USAGE'));
END $$;

ROLLBACK;
