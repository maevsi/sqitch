BEGIN;

SELECT id,
       fcm_token,
       created_at,
       created_by
       updated_at,
       updated_by
FROM vibetype.device WHERE FALSE;

SELECT vibetype_test.index_existence(
  ARRAY ['idx_device_updated_by', 'device_created_by_fcm_token_key']
);

ROLLBACK;
