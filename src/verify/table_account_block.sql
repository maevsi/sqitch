BEGIN;

SELECT id,
       blocked_account_id,
       created_at,
       created_by
FROM maevsi.account_block WHERE FALSE;

SELECT maevsi_test.index_existence(
  ARRAY ['account_block_created_by_blocked_account_id_key']
);

ROLLBACK;
