BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.achievement_unlock(UUID, TEXT)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.achievement_unlock(UUID, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
