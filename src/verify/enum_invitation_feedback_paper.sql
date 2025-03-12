BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.invitation_feedback_paper', 'USAGE'));
END $$;

ROLLBACK;
