BEGIN;

SELECT created_at,
       account_id,
       event_size
FROM maevsi.account_preference_event_size WHERE FALSE;

ROLLBACK;
