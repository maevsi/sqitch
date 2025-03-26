BEGIN;

SELECT account_id,
       category
FROM vibetype.account_preference_event_category WHERE FALSE;

ROLLBACK;
