BEGIN;

SELECT id,
       blocked_account_id,
       created_at,
       created_by
FROM maevsi.account_block WHERE FALSE;

ROLLBACK;
