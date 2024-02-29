-- Verify maevsi:enum_event_category on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.event_category', 'USAGE'));
END $$;

ROLLBACK;
