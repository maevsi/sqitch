BEGIN;

SELECT id,
       channel,
       is_acknowledged,
       payload,
       created_at
FROM maevsi_private.notification WHERE FALSE;

ROLLBACK;
