BEGIN;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.account_registration_refresh(UUID, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.account_registration_refresh(UUID, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
