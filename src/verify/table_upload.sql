BEGIN;

SELECT id,
       account_id,
       size_byte,
       storage_key
FROM maevsi.upload WHERE FALSE;

ROLLBACK;
