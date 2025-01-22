BEGIN;

CREATE EXTENSION pgcrypto WITH SCHEMA public;

COMMENT ON EXTENSION pgcrypto IS 'Provides password hashing functions.';

COMMIT;
