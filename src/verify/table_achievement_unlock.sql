-- Verify maevsi:table_achievement_unlock on pg

BEGIN;

SELECT id,
       account_id,
       achievement,
       level
FROM maevsi.achievement_unlock WHERE FALSE;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.achievement_unlock', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.achievement_unlock', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.achievement_unlock', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.achievement_unlock', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.achievement_unlock', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.achievement_unlock', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.achievement_unlock', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.achievement_unlock', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_stomper', 'maevsi.achievement_unlock', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_stomper', 'maevsi.achievement_unlock', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_stomper', 'maevsi.achievement_unlock', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_stomper', 'maevsi.achievement_unlock', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.achievement_unlock', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.achievement_unlock', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.achievement_unlock', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.achievement_unlock', 'DELETE'));
END $$;

ROLLBACK;
