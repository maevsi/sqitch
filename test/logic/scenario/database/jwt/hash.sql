\echo test_table_jwt_hash...

BEGIN;

-- Signing in replaces a hash with a lower work factor, and only then.
SAVEPOINT hash;
DO $$
DECLARE
  _account_id UUID;
  _hash TEXT;
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  UPDATE vibetype_private.account
    SET password_hash = public.crypt('password', public.gen_salt('bf', 6))
    WHERE id = _account_id
    RETURNING password_hash INTO _hash;

  IF vibetype.jwt_create('username', 'password_incorrect') IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: an incorrect password signed in';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM vibetype_private.account WHERE id = _account_id AND password_hash = _hash) THEN
    RAISE EXCEPTION 'Test failed: a failed sign-in changed the password hash';
  END IF;

  IF vibetype.jwt_create('username', 'password') IS NULL THEN
    RAISE EXCEPTION 'Test failed: the password does not sign in against a hash with a lower work factor';
  END IF;

  SELECT password_hash INTO _hash FROM vibetype_private.account WHERE id = _account_id;

  IF _hash NOT LIKE '$2a$10$%' THEN
    RAISE EXCEPTION 'Test failed: the sign-in did not replace the hash with a lower work factor';
  END IF;

  IF vibetype.jwt_create('email@example.com', 'password') IS NULL THEN
    RAISE EXCEPTION 'Test failed: the password does not sign in against the replaced hash';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM vibetype_private.account WHERE id = _account_id AND password_hash = _hash) THEN
    RAISE EXCEPTION 'Test failed: a sign-in replaced a hash that already had the expected work factor';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT hash;

-- An unknown account or an unverified email address does not sign in.
SAVEPOINT unknown;
DO $$
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  IF vibetype.jwt_create('unknown', 'password') IS NOT NULL OR vibetype.jwt_create('unknown@example.com', 'password') IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: an unknown account signed in';
  END IF;

  PERFORM vibetype.account_registration('1970-01-01', 'email@example.com', 'en', vibetype_test.legal_term_select_by_singleton(), 'password', 'username');

  IF vibetype.jwt_create('username', 'password') IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: an account with an unverified email address signed in';
  END IF;

  IF EXISTS (SELECT 1 FROM vibetype_private.jwt) THEN
    RAISE EXCEPTION 'Test failed: a failed sign-in stored a session';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT unknown;

ROLLBACK;
