BEGIN;

SELECT account_id,
       category
FROM maevsi.account_interest WHERE FALSE;

ROLLBACK;
