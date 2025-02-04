BEGIN;

SELECT id,
       messaging_id,
       created_at,
       created_by
      --  updated_at,
      --  updated_by
FROM maevsi.device WHERE FALSE;

-- SELECT maevsi_test.index_existence(
--   ARRAY ['device_created_by_messaging_id']
-- );

ROLLBACK;
