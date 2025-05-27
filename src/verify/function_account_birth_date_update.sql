BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_birth_date_update(DATE)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_birth_date_update(DATE)', 'EXECUTE'));
END $$;

ROLLBACK;
