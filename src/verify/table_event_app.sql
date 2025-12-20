BEGIN;

SELECT id,
       app_id,
       event_id,
       created_at,
       created_by
FROM vibetype.event_app WHERE FALSE;

ROLLBACK;
