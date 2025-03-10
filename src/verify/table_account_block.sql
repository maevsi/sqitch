BEGIN;

SELECT id,
       blocked_account_id,
       created_at,
       created_by
FROM vibetype.account_block WHERE FALSE;

SELECT vibetype_test.index_existence(
  ARRAY ['account_block_created_by_blocked_account_id_key']
);

ROLLBACK;
