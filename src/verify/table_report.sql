BEGIN;

SELECT id,
       reason,
       target_account_id,
       target_event_id,
       target_upload_id,
       created_at,
       created_by
FROM vibetype.report WHERE FALSE;

ROLLBACK;
