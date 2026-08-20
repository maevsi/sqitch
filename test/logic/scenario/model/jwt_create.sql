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

-- A primary email address that's pending (re-)verification must not be usable to log in, the same
-- way account_password_reset_request already refuses to act on one (aea.verification IS NULL).
SAVEPOINT email_verification_pending;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');
  PERFORM vibetype_test.account_email_address_verification_pend(_account_id);

  BEGIN
    _jwt := vibetype.jwt_create('email@example.com', 'password');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication by email should not have returned a JWT while verification is pending';
  END IF;

  -- Username-based login doesn't go through the email lookup, so it must be unaffected.
  _jwt := vibetype.jwt_create('username', 'password');
  IF _jwt IS NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication by username should still have returned a JWT while the email''s verification is pending';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_verification_pending;

ROLLBACK;
