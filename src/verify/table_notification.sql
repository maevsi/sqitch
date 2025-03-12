BEGIN;

SELECT id,
       channel,
       is_acknowledged,
       payload,
       created_at
FROM vibetype_private.notification WHERE FALSE;

ROLLBACK;
