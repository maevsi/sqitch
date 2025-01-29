BEGIN;

SELECT id,
       account_id,
       name,
       size_byte,
       storage_key,
       type,
       created_at
FROM maevsi.upload WHERE FALSE;

ROLLBACK;
