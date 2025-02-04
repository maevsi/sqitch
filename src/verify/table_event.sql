BEGIN;

SELECT id,
       address_id,
       description,
       "end",
       guest_count_maximum,
       is_archived,
       is_in_person,
       is_remote,
       location,
       location_geography,
       name,
       slug,
       start,
       url,
       visibility,
       created_at,
       created_by,
       search_vector
FROM maevsi.event WHERE FALSE;

-- TODO: extract to helper function
WITH expected_indexes AS (
    SELECT unnest(ARRAY['idx_event_location', 'idx_event_created_by', 'idx_event_search_vector']) AS indexname
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

ROLLBACK;
