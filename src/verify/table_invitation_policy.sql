-- Verify maevsi:table_invitation_policy on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.invitation', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.invitation', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.invitation', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.invitation', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.invitation', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.invitation', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.invitation', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.invitation', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.invitation', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.invitation', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.invitation', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.invitation', 'DELETE'));

  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.trigger_invitation_update()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.trigger_invitation_update()', 'EXECUTE'));
END $$;

ROLLBACK;
