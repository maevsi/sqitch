BEGIN;

SELECT id,
       event_id,
       feedback,
       feedback_paper,
       created_at,
       updated_at,
       updated_by
FROM maevsi.guest WHERE FALSE;

-- TODO: extract to helper function
WITH expected_indexes AS (
    SELECT unnest(ARRAY['idx_guest_contact_id', 'idx_guest_event_id']) AS indexname
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
