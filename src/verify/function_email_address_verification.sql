BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.email_address_verification(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.email_address_verification(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
