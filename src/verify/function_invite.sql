-- Verify maevsi:function_invite on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.invite(UUID, TEXT)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.invite(UUID, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
