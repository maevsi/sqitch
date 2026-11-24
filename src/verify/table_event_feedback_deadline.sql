BEGIN;

SELECT feedback_deadline FROM vibetype.event WHERE FALSE;
SELECT 'vibetype_private.trigger_guest_feedback_deadline()'::regprocedure;

ROLLBACK;
