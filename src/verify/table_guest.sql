BEGIN;

SELECT id,
       event_id,
       feedback,
       feedback_override,
       feedback_reason,
       created_at,
       updated_at,
       updated_by
FROM vibetype.guest WHERE FALSE;

ROLLBACK;
