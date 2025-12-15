\echo test_table_jwt_generated_columns...

BEGIN;

SAVEPOINT jwt_generated_columns;
DO $$
DECLARE
  _jwt vibetype.jwt;
  _row RECORD;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');
  _jwt := vibetype.jwt_create('username', 'password');

  SELECT * INTO _row FROM vibetype_private.jwt WHERE id = _jwt.jti;

  IF _row.expiry IS NULL OR _row.subject IS NULL THEN
    RAISE EXCEPTION 'Test failed: generated columns should be populated from token claims';
  END IF;

  IF _row.expiry <> to_timestamp(_jwt.exp) THEN
    RAISE EXCEPTION 'Test failed: expiry generated column mismatch';
  END IF;

  IF _row.subject <> _jwt.sub THEN
    RAISE EXCEPTION 'Test failed: subject generated column mismatch';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT jwt_generated_columns;

ROLLBACK;
