BEGIN;

CREATE TYPE vibetype.language AS ENUM (
  'de',
  'en'
);

COMMENT ON TYPE vibetype.language IS 'Supported ISO 639 language codes.';

COMMIT;
