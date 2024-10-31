-- Verify maevsi:table_account_event_size_pref on pg

BEGIN;

SELECT account_id,
       event_size
FROM maevsi.account_event_size_pref WHERE FALSE;

ROLLBACK;
