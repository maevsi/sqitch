-- Verify maevsi:table_user_interest on pg

BEGIN;

SELECT user_id,
       category
FROM maevsi.table_user_interest WHERE FALSE;

ROLLBACK;
