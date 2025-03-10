BEGIN;

SELECT id,
       event_id,
       created_at,
       created_by
FROM vibetype.event_favorite WHERE FALSE;

ROLLBACK;
