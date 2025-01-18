BEGIN;

SELECT id,
       author_account_id,
       blocked_account_id,
       created_at
FROM maevsi.account_block WHERE FALSE;

ROLLBACK;
