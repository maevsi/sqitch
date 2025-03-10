BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_password_reset_request(TEXT, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_password_reset_request(TEXT, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
