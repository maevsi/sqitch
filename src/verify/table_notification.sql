BEGIN;

SELECT id,
       channel,
       created_at,
       is_acknowledged,
       payload
FROM maevsi_private.notification WHERE FALSE;

ROLLBACK;
