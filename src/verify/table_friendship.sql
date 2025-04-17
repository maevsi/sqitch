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
FROM vibetype.friendship
WHERE FALSE;

ROLLBACK;
