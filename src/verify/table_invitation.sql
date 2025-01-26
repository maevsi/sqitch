BEGIN;

SELECT id,
       event_id,
       feedback,
       feedback_paper,
       created_at,
       updated_at,
       updated_by
FROM maevsi.invitation WHERE FALSE;

ROLLBACK;
