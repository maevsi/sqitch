BEGIN;

SELECT id,
       fcm_token,
       created_at,
       created_by
       updated_at,
       updated_by
FROM vibetype.device WHERE FALSE;


ROLLBACK;
