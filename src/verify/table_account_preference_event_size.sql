BEGIN;

SELECT account_id,
       event_size,
       created_at
FROM vibetype.account_preference_event_size WHERE FALSE;

ROLLBACK;
