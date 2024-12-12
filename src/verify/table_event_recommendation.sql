BEGIN;

SELECT account_id,
       event_id,
       score,
       predicted_score
FROM maevsi.event_recommendation WHERE FALSE;

ROLLBACK;
