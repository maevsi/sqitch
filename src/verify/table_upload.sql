-- Verify maevsi:table_upload on pg

BEGIN;

SELECT id,
       account_id,
       name,
       size_byte,
       storage_key,
       type
FROM maevsi.upload WHERE FALSE;

ROLLBACK;
