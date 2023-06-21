-- Verify maevsi:function_account_username_by_id on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.account_username_by_id(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.account_username_by_id(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
