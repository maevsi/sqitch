BEGIN;

SELECT id,
       fcm_token,
       created_at,
       created_by
       updated_at,
       updated_by
FROM maevsi.device WHERE FALSE;

SELECT maevsi_test.index_existence(
  ARRAY ['idx_device_updated_by', 'device_created_by_fcm_token_key']
);

ROLLBACK;
