BEGIN;

SELECT account_id,
       category
FROM vibetype.account_interest WHERE FALSE;

ROLLBACK;
