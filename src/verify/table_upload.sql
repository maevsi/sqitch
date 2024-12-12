BEGIN;

SELECT id,
       created_at,
       account_id,
       size_byte,
       storage_key
FROM maevsi.upload WHERE FALSE;

ROLLBACK;
