BEGIN;

SELECT account_id,
       category_id
FROM vibetype.account_preference_event_category WHERE FALSE;

ROLLBACK;
