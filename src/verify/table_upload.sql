BEGIN;

SELECT id,
       created_at,
       account_id,
       name,
       size_byte,
       storage_key,
       type
FROM maevsi.upload WHERE FALSE;

ROLLBACK;
