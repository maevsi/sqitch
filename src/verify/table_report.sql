-- Verify maevsi:table_report on pg

BEGIN;

SELECT id,
       reporter_id,
       reason,
       event_id,
       upload_id,
       user_id
FROM maevsi.report WHERE FALSE;

ROLLBACK;
