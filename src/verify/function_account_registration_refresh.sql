BEGIN;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_registration_refresh(UUID, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_registration_refresh(UUID, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
