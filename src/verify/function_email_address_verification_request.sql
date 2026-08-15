BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.email_address_verification_request(TEXT, TEXT, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.email_address_verification_request(TEXT, TEXT, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
