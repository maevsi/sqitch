BEGIN;

SELECT id,
       event_id,
       upload_id
FROM maevsi.event_upload WHERE FALSE;
