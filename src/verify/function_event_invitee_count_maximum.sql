BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.event_invitee_count_maximum(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.event_invitee_count_maximum(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
