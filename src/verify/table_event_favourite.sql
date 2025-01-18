BEGIN;

SELECT account_id,
       event_id
FROM maevsi.event_favourite WHERE FALSE;

ROLLBACK;
