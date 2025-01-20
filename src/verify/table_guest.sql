BEGIN;

SELECT id,
       created_at,
       updated_at,
       updated_by,
       event_id,
       feedback,
       feedback_paper
FROM maevsi.guest WHERE FALSE;

ROLLBACK;
