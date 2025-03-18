BEGIN;

SELECT id,
       event_id,
       upload_id
FROM vibetype.event_upload WHERE FALSE;
