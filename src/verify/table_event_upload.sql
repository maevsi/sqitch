BEGIN;

SELECT id,
       event_id,
       is_header_image,
       upload_id
FROM vibetype.event_upload WHERE FALSE;
