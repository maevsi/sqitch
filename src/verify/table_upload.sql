BEGIN;

SELECT id,
       account_id,
       name,
       size_byte,
       storage_key,
       type,
       created_at
FROM vibetype.upload WHERE FALSE;

ROLLBACK;
