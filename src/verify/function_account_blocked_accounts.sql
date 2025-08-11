BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_blocked_accounts()', 'EXECUTE'));
END $$;

ROLLBACK;
