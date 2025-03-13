BEGIN;

SELECT id,
       channel,
       is_acknowledged,
       payload,
       created_at
FROM maevsi.notification WHERE FALSE;

ROLLBACK;
