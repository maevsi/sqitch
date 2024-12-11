-- Verify maevsi:enum_event_size on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.event_size', 'USAGE'));
END $$;

ROLLBACK;
