BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.invitation_action', 'USAGE'));
END $$;

ROLLBACK;
