BEGIN;

SELECT id,
       event_id,
       feedback,
       feedback_paper
FROM maevsi.invitation WHERE FALSE;

ROLLBACK;
