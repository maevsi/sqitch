BEGIN;

SELECT id,
       created_at,
       author_account_id,
       reason,
       target_account_id,
       target_event_id,
       target_upload_id
FROM maevsi.report WHERE FALSE;

ROLLBACK;
