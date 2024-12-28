BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.achievement_unlock(UUID, TEXT)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.achievement_unlock(UUID, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
