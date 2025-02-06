BEGIN;

SELECT id,
       event_id,
       created_at,
       created_by
FROM maevsi.event_favorite WHERE FALSE;

ROLLBACK;
