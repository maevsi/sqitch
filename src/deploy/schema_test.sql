BEGIN;

CREATE SCHEMA vibetype_test;

COMMENT ON SCHEMA vibetype_test IS 'Schema for test functions.';

GRANT USAGE ON SCHEMA vibetype_test TO vibetype_anonymous, vibetype_account;

COMMIT;
