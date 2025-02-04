BEGIN;

SELECT id,
       blocked_account_id,
       created_at,
       created_by
FROM maevsi.account_block WHERE FALSE;

SELECT maevsi_test.index_existence(
  ARRAY ['idx_account_block_blocked_account_id', 'idx_account_block_created_by']
);

ROLLBACK;
