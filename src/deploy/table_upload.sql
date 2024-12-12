-- Deploy maevsi:table_event to pg
-- requires: schema_public
-- requires: table_account_public

BEGIN;

CREATE TABLE maevsi.upload (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id     UUID NOT NULL REFERENCES maevsi.account(id),
  name           TEXT CHECK (char_length("name") > 0 AND char_length("name") < 300),
  size_byte      BIGINT NOT NULL CHECK (size_byte > 0),
  storage_key    TEXT UNIQUE,
  type           TEXT NOT NULL DEFAULT 'image'
);

COMMENT ON TABLE maevsi.upload IS 'An upload.';
COMMENT ON COLUMN maevsi.upload.id IS E'@omit create,update\nThe upload''s internal id.';
COMMENT ON COLUMN maevsi.upload.account_id IS 'The uploader''s account id.';
COMMENT ON COLUMN maevsi.upload.name IS 'The name of the uploaded file.';
COMMENT ON COLUMN maevsi.upload.size_byte IS 'The upload''s size in bytes.';
COMMENT ON COLUMN maevsi.upload.storage_key IS 'The upload''s storage key.';
COMMENT ON COLUMN maevsi.upload.type IS 'The type of the uploaded file, default is ''image''.';

COMMIT;
