BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.invitation_feedback_paper', 'USAGE'));
END $$;

ROLLBACK;
