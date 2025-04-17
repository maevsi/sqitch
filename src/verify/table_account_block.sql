BEGIN;

SELECT id,
       blocked_account_id,
       created_at,
       created_by
FROM vibetype.account_block WHERE FALSE;

ROLLBACK;
