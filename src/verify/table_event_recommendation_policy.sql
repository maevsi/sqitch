-- Verify maevsi:table_event_recommendation_policy on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_recommendation', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_recommendation', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_recommendation', 'DELETE'));
  ASSERT NOT(SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_recommendation', 'UPDATE'));
END $$;

ROLLBACK;
