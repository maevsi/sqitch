BEGIN;

SELECT id,
       event_group_id,
       event_id
FROM maevsi.event_grouping WHERE FALSE;

-- TODO: extract to helper function
WITH expected_indexes AS (
    SELECT unnest(ARRAY['idx_event_grouping_event_group_id', 'idx_event_grouping_event_id']) AS indexname
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
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_grouping', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_grouping', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_grouping', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_grouping', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_grouping', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_grouping', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_grouping', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_grouping', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.event_grouping', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.event_grouping', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.event_grouping', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.event_grouping', 'DELETE'));
END $$;

ROLLBACK;
