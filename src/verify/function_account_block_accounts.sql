BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_block_accounts()', 'EXECUTE'));
END $$;

ROLLBACK;
