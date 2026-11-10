BEGIN;

ALTER TABLE vibetype.upload REPLICA IDENTITY FULL;
DROP TRIGGER outbox ON vibetype.upload;
DROP FUNCTION vibetype.trigger_upload_outbox();

COMMIT;
