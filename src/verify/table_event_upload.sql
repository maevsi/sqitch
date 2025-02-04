BEGIN;

SELECT id,
       event_id,
       is_header_image,
       upload_id
FROM maevsi.event_upload WHERE FALSE;
