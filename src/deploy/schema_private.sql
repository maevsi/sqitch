BEGIN;

CREATE SCHEMA vibetype_private;

COMMENT ON SCHEMA vibetype_private IS 'Contains account information and is not used by PostGraphile.';

COMMIT;
