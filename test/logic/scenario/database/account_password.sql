\echo test_account_password...

BEGIN;

-- A changed password keeps the session it was changed in and ends the others.
SAVEPOINT password_change;
DO $$
DECLARE
  _account_id UUID;
  _jti_current UUID;
  _jti_other UUID;
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  IF NOT EXISTS (SELECT 1 FROM vibetype_private.account WHERE id = _account_id AND password_hash LIKE '$2a$10$%') THEN
    RAISE EXCEPTION 'Test failed: the password hash of a registration does not use the expected work factor';
  END IF;

  _jti_current := (vibetype.jwt_create('username', 'password')).jti;
  _jti_other := (vibetype.jwt_create('username', 'password')).jti;

  PERFORM set_config('jwt.claims.sub', _account_id::TEXT, true);
  PERFORM set_config('jwt.claims.jti', _jti_current::TEXT, true);
  PERFORM vibetype.account_password_change('password', 'password-new');

  IF NOT EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE id = _jti_current) THEN
    RAISE EXCEPTION 'Test failed: the session the password was changed in has ended';
  END IF;

  IF EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE id = _jti_other) THEN
    RAISE EXCEPTION 'Test failed: another session survived the password change';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM vibetype_private.account WHERE id = _account_id AND password_hash LIKE '$2a$10$%') THEN
    RAISE EXCEPTION 'Test failed: the password hash of a password change does not use the expected work factor';
  END IF;

  IF vibetype.jwt_create('username', 'password-new') IS NULL THEN
    RAISE EXCEPTION 'Test failed: the new password does not sign in';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT password_change;

-- A reset password ends every session.
SAVEPOINT password_reset;
DO $$
DECLARE
  _account_id UUID;
  _code UUID;
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  PERFORM vibetype.jwt_create('username', 'password');
  PERFORM vibetype.jwt_create('username', 'password');

  PERFORM vibetype.account_password_reset_request('email@example.com', 'en');
  SELECT password_reset_verification INTO _code FROM vibetype_private.account WHERE id = _account_id;
  PERFORM vibetype.account_password_reset(_code, 'password-new');

  IF EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE subject = _account_id) THEN
    RAISE EXCEPTION 'Test failed: a session survived the password reset';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM vibetype_private.account WHERE id = _account_id AND password_hash LIKE '$2a$10$%') THEN
    RAISE EXCEPTION 'Test failed: the password hash of a password reset does not use the expected work factor';
  END IF;

  IF vibetype.jwt_create('username', 'password-new') IS NULL THEN
    RAISE EXCEPTION 'Test failed: the new password does not sign in';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT password_reset;

-- A registration with a known email address stays silent and creates nothing.
SAVEPOINT registration_email_known;
DO $$
DECLARE
  _count INTEGER;
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  PERFORM vibetype_test.account_registration_verified('username', 'email@example.com');
  PERFORM vibetype.account_registration('1970-01-01', 'email@example.com', 'en', vibetype_test.legal_term_select_by_singleton(), 'password', 'other');

  SELECT COUNT(*) INTO _count FROM vibetype_private.account;

  IF _count != 1 THEN
    RAISE EXCEPTION 'Test failed: expected 1 account after registering a known email address, found %', _count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT registration_email_known;

ROLLBACK;
