BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.friendship_account_ids()', 'EXECUTE'));
END $$;

COMMIT;
