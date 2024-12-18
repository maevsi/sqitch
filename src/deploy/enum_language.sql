BEGIN;

CREATE TYPE maevsi.language AS ENUM (
  'de',
  'en'
);

COMMENT ON TYPE maevsi.language IS 'Supported ISO 639 language codes.';

COMMIT;
