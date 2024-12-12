BEGIN;

CREATE EXTENSION pgcrypto WITH SCHEMA maevsi;

COMMENT ON EXTENSION pgcrypto IS 'Provides password hashing functions.';

COMMIT;
