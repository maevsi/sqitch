\echo test_table_jwt_language...

BEGIN;

-- Signing in takes the language of the own contact, which may be unset.
SAVEPOINT jwt_create;
DO $$
DECLARE
  _account_id UUID;
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  IF (vibetype.jwt_create('username', 'password')).language IS DISTINCT FROM 'en' THEN
    RAISE EXCEPTION 'Test failed: the sign-in did not take the language of the own contact';
  END IF;

  UPDATE vibetype.contact SET language = NULL WHERE account_id = _account_id AND created_by = _account_id;

  IF (vibetype.jwt_create('username', 'password')).language IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: the sign-in set a language the own contact does not have';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT jwt_create;

-- A refresh takes the current language of the own contact, and adding a claim keeps it.
SAVEPOINT jwt_update;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');
  _jwt := vibetype.jwt_create('username', 'password');

  UPDATE vibetype.contact SET language = 'de' WHERE account_id = _account_id AND created_by = _account_id;

  _jwt := vibetype.jwt_update(_jwt.jti);

  IF _jwt.language IS DISTINCT FROM 'de' OR (SELECT (token).language FROM vibetype_private.jwt WHERE id = _jwt.jti) IS DISTINCT FROM 'de' THEN
    RAISE EXCEPTION 'Test failed: the refresh did not take the changed language of the own contact';
  END IF;

  PERFORM set_config('jwt.claims.exp', _jwt.exp::TEXT, true);
  PERFORM set_config('jwt.claims.jti', _jwt.jti::TEXT, true);
  PERFORM set_config('jwt.claims.language', _jwt.language::TEXT, true);
  PERFORM set_config('jwt.claims.role', _jwt.role, true);
  PERFORM set_config('jwt.claims.sub', _account_id::TEXT, true);
  PERFORM set_config('jwt.claims.username', _jwt.username, true);

  IF (vibetype.jwt_update_guest_add(gen_random_uuid())).language IS DISTINCT FROM 'de' THEN
    RAISE EXCEPTION 'Test failed: adding a guest claim dropped the language';
  END IF;

  IF (vibetype.jwt_update_attendance_add(gen_random_uuid())).language IS DISTINCT FROM 'de' THEN
    RAISE EXCEPTION 'Test failed: adding an attendance claim dropped the language';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT jwt_update;

-- A session without an account has no language, also after a refresh.
SAVEPOINT anonymous;
DO $$
DECLARE
  _jwt vibetype.jwt;
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  PERFORM set_config('jwt.claims.jti', '', true);

  _jwt := vibetype.jwt_update_guest_add(gen_random_uuid());

  IF _jwt.language IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: a session without an account has a language';
  END IF;

  _jwt := vibetype.jwt_update(_jwt.jti);

  IF _jwt IS NULL OR _jwt.language IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: a refreshed session without an account has a language';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT anonymous;

ROLLBACK;
