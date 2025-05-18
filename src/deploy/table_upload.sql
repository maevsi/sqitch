BEGIN;

CREATE TABLE vibetype.upload (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  name          TEXT CHECK (char_length("name") > 0 AND char_length("name") < 300),
  size_byte     BIGINT NOT NULL CHECK (size_byte > 0),
  storage_key   TEXT UNIQUE,
  type          TEXT NOT NULL DEFAULT 'image',

  created_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by    UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE
);

COMMENT ON TABLE vibetype.upload IS 'An upload.';
COMMENT ON COLUMN vibetype.upload.id IS E'@omit create,update\nThe upload''s internal id.';
COMMENT ON COLUMN vibetype.upload.name IS 'The name of the uploaded file.';
COMMENT ON COLUMN vibetype.upload.size_byte IS E'@omit update\nThe upload''s size in bytes.';
COMMENT ON COLUMN vibetype.upload.storage_key IS E'@omit create,update\nThe upload''s storage key.';
COMMENT ON COLUMN vibetype.upload.type IS E'@omit create,update\nThe type of the uploaded file, default is ''image''.';
COMMENT ON COLUMN vibetype.upload.created_at IS E'@omit create,update\nTimestamp of when the upload was created, defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.upload.created_by IS 'The uploader''s account id.';

ALTER TABLE vibetype.upload REPLICA IDENTITY FULL;

COMMIT;
