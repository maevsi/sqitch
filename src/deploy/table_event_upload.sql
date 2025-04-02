BEGIN;

CREATE TABLE vibetype.event_upload (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  event_id          UUID NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,
  is_header_image   BOOLEAN,
  upload_id         UUID NOT NULL REFERENCES vibetype.upload(id) ON DELETE CASCADE,

  UNIQUE (event_id, upload_id)
);

CREATE UNIQUE INDEX idx_event_upload_is_header_image_unique
  ON vibetype.event_upload USING btree (event_id)
  WHERE (is_header_image = true);

COMMENT ON TABLE vibetype.event_upload IS 'Associates uploaded files with events.';
COMMENT ON COLUMN vibetype.event_upload.id IS E'@omit create,update\nPrimary key, uniquely identifies each event-upload association.';
COMMENT ON COLUMN vibetype.event_upload.event_id IS E'@omit update\nReference to the event associated with the upload.';
COMMENT ON COLUMN vibetype.event_upload.is_header_image IS 'Optional boolean flag indicating if the upload is the header image for the event.';
COMMENT ON COLUMN vibetype.event_upload.upload_id IS E'@omit update\nReference to the uploaded file.';
COMMENT ON CONSTRAINT event_upload_event_id_upload_id_key ON vibetype.event_upload IS 'Ensures that each upload is associated with a unique event, preventing duplicate uploads for the same event.';
COMMENT ON INDEX vibetype.idx_event_upload_is_header_image_unique IS 'Ensures that at most one header image exists per event.';

END;
