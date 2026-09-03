BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

COMMENT ON EXTENSION pgcrypto IS 'Provides password hashing functions.';

COMMIT;
