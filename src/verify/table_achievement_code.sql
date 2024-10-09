-- Verify maevsi:table_achievement_code on pg

BEGIN;

SELECT id,
       alias,
       achievement
FROM maevsi_private.achievement_code WHERE FALSE;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi_private.achievement_code', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi_private.achievement_code', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi_private.achievement_code', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi_private.achievement_code', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi_private.achievement_code', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi_private.achievement_code', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi_private.achievement_code', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi_private.achievement_code', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi_private.achievement_code', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi_private.achievement_code', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi_private.achievement_code', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi_private.achievement_code', 'DELETE'));
END $$;

ROLLBACK;
