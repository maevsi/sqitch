BEGIN;

SELECT id,
       event_id,
       feedback,
       feedback_override,
       feedback_reason,
       companion_count,
       companion_count_requested,
       created_at,
       updated_at,
       updated_by
FROM vibetype.guest WHERE FALSE;

ROLLBACK;
