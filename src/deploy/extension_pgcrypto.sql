BEGIN;

CREATE EXTENSION pgcrypto;

COMMENT ON EXTENSION pgcrypto IS 'Provides password hashing functions.';

COMMIT;
