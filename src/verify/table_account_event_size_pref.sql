-- Verify maevsi:table_account_preference_event_size on pg

BEGIN;

SELECT account_id,
       event_size
FROM maevsi.account_preference_event_size WHERE FALSE;

ROLLBACK;
