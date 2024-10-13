
-- Verify maevsi:table_account_block on pg

BEGIN;

SELECT id,
       author_account_id,
       blocked_account_id,
       created
FROM maevsi.account_block WHERE FALSE;

ROLLBACK;
