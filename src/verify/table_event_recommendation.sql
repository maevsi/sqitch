BEGIN;

SELECT account_id,
       event_id,
       score,
       predicted_score
FROM vibetype.event_recommendation WHERE FALSE;

ROLLBACK;
