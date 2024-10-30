-- Verify maevsi:function_event_size on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.event_size(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.event_size(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
