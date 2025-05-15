BEGIN;

SELECT id,
       name,
       size_byte,
       storage_key,
       type,
       created_by,
       created_at
FROM vibetype.upload WHERE FALSE;

ROLLBACK;
