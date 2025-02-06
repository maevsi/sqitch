BEGIN;

CREATE SCHEMA maevsi_test;

COMMENT ON SCHEMA maevsi_test IS 'Schema for test functions.';

GRANT USAGE ON SCHEMA maevsi_test TO maevsi_anonymous, maevsi_account;

COMMIT;
