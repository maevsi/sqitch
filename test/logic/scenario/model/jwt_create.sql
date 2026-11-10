\echo test_jwt_create...

BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.jwt_create(TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.jwt_create(TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

SAVEPOINT username_success;
DO $$
DECLARE
  _jwt vibetype.jwt;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  _jwt := vibetype.jwt_create('username', 'password');

  IF _jwt IS NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should have returned a JWT';
  END IF;

  IF _jwt.username <> 'username' THEN
    RAISE EXCEPTION 'Test failed: JWT contains an incorrect username';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT username_success;

SAVEPOINT username_incorrect;
DO $$
DECLARE
  _jwt vibetype.jwt;

BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  BEGIN
    _jwt := vibetype.jwt_create('username_incorrect', 'password');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT username_incorrect;

SAVEPOINT username_password_incorrect;
DO $$
DECLARE
  _jwt vibetype.jwt;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  BEGIN
    _jwt := vibetype.jwt_create('username', 'password_incorrect');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should not have returned a JWT';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT username_password_incorrect;

SAVEPOINT email_success;
DO $$
DECLARE
  _jwt vibetype.jwt;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');
  _jwt := vibetype.jwt_create('email@example.com', 'password');

  IF _jwt IS NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should have returned a JWT';
  END IF;

  IF _jwt.username <> 'username' THEN
    RAISE EXCEPTION 'Test failed: JWT contains an incorrect user name';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_success;

SAVEPOINT email_incorrect;
DO $$
DECLARE
  _jwt vibetype.jwt;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  BEGIN
    _jwt := vibetype.jwt_create('email_incorrect@example.com', 'password');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should not have returned a JWT';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_incorrect;

SAVEPOINT email_password_incorrect;
DO $$
DECLARE
  _jwt vibetype.jwt;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  BEGIN
    _jwt := vibetype.jwt_create('email@example.com', 'password_incorrect');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should not have returned a JWT';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_password_incorrect;

ROLLBACK;
