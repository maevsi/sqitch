BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.account_password_reset(UUID, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.account_password_reset(UUID, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
