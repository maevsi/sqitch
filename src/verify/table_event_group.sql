BEGIN;

SELECT id,
       description,
       is_archived,
       name,
       slug,
       created_at,
       created_by
FROM maevsi.event_group WHERE FALSE;

-- TODO: extract to helper function
WITH expected_indexes AS (
    SELECT unnest(ARRAY['idx_event_group_created_by']) AS indexname
),
existing_indexes AS (
    SELECT indexname FROM pg_indexes
    WHERE schemaname = 'maevsi'
    AND indexname IN (SELECT indexname FROM expected_indexes)
)
SELECT 1 / NULLIF(
    0,
    (SELECT COUNT(*) FROM existing_indexes) -
    (SELECT COUNT(*) FROM expected_indexes)
) AS status;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_group', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_group', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_group', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_group', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_group', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_group', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_group', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_group', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.event_group', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.event_group', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.event_group', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.event_group', 'DELETE'));
END $$;

ROLLBACK;
