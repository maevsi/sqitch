-- Verify maevsi:table_report on pg

BEGIN;

SELECT id,
       author_account_id,
       reason,
       target_account_id,
       target_event_id,
       target_upload_id,
       created_at
FROM maevsi.report WHERE FALSE;

ROLLBACK;
