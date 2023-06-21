-- Verify maevsi:function_account_id_by_username on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.account_id_by_username(TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.account_id_by_username(TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
