BEGIN;

SELECT
  id,
  a_account_id,
  b_account_id,
  status,
  created_at,
  created_by,
  updated_at,
  updated_by
FROM maevsi.friendship
WHERE FALSE;

SELECT maevsi_test.index_existence(
  ARRAY ['idx_friendship_created_by', 'idx_friendship_updated_by']
);

ROLLBACK;
