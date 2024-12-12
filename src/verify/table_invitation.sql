BEGIN;

SELECT id,
       created_at,
       event_id,
       feedback,
       feedback_paper
FROM maevsi.invitation WHERE FALSE;

ROLLBACK;
