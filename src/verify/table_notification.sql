BEGIN;

SELECT id,
       channel,
       is_acknowledged,
       payload,
       "timestamp"
FROM maevsi_private.notification WHERE FALSE;

ROLLBACK;
