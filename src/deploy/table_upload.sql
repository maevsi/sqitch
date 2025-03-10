BEGIN;

CREATE TABLE vibetype.upload (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id     UUID NOT NULL REFERENCES vibetype.account(id),
  name           TEXT CHECK (char_length("name") > 0 AND char_length("name") < 300),
  size_byte      BIGINT NOT NULL CHECK (size_byte > 0),
  storage_key    TEXT UNIQUE,
  type           TEXT NOT NULL DEFAULT 'image',

  created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vibetype.upload IS 'An upload.';
COMMENT ON COLUMN vibetype.upload.id IS E'@omit create,update\nThe upload''s internal id.';
COMMENT ON COLUMN vibetype.upload.account_id IS 'The uploader''s account id.';
COMMENT ON COLUMN vibetype.upload.name IS 'The name of the uploaded file.';
COMMENT ON COLUMN vibetype.upload.size_byte IS 'The upload''s size in bytes.';
COMMENT ON COLUMN vibetype.upload.storage_key IS 'The upload''s storage key.';
COMMENT ON COLUMN vibetype.upload.type IS 'The type of the uploaded file, default is ''image''.';
COMMENT ON COLUMN vibetype.upload.created_at IS E'@omit create,update\nTimestamp of when the upload was created, defaults to the current timestamp.';

COMMIT;
