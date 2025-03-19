BEGIN;

SELECT id,
       channel,
       is_acknowledged,
       payload,
       created_at
FROM vibetype.notification WHERE FALSE;

ROLLBACK;
