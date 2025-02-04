BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.friend_ids()', 'EXECUTE'));
END $$;

COMMIT;
