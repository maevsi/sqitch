-- Verify maevsi:table_account_interest on pg

BEGIN;

SELECT account_id,
       category
FROM maevsi.account_interest WHERE FALSE;

ROLLBACK;
