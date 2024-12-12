-- Deploy maevsi:table_event_upload to pg

BEGIN;

CREATE TABLE maevsi.event_upload (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id          UUID NOT NULL REFERENCES maevsi.event(id),
  upload_id         UUID NOT NULL REFERENCES maevsi.upload(id),
  UNIQUE (event_id, upload_id)
);

COMMENT ON TABLE maevsi.event_upload IS 'An assignment of an uploaded content (e.g. an image) to an event.';
COMMENT ON COLUMN maevsi.event_upload.id IS '@omit insert,update\nThe event''s internal id for which the invitation is valid.';
COMMENT ON COLUMN maevsi.event_upload.event_id IS '@omit update,delete\nThe event''s internal id for which the invitation is valid.';
COMMENT ON COLUMN maevsi.event_upload.upload_id IS '@omit update,delete\nThe internal id of the uploaded content.';

END;
