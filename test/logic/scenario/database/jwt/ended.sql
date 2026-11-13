\echo test_table_jwt_ended...

BEGIN;

-- Adding a claim to a session that has ended neither returns a token nor stores the session again.
SAVEPOINT ended;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');
  _jwt := vibetype.jwt_create('username', 'password');

  PERFORM set_config('jwt.claims.exp', _jwt.exp::TEXT, true);
  PERFORM set_config('jwt.claims.jti', _jwt.jti::TEXT, true);
  PERFORM set_config('jwt.claims.role', _jwt.role, true);
  PERFORM set_config('jwt.claims.sub', _account_id::TEXT, true);
  PERFORM set_config('jwt.claims.username', _jwt.username, true);

  IF vibetype.jwt_update_guest_add(gen_random_uuid()) IS NULL THEN
    RAISE EXCEPTION 'Test failed: a guest claim could not be added to a running session';
  END IF;

  IF vibetype.jwt_update_attendance_add(gen_random_uuid()) IS NULL THEN
    RAISE EXCEPTION 'Test failed: an attendance claim could not be added to a running session';
  END IF;

  DELETE FROM vibetype_private.jwt WHERE id = _jwt.jti;

  IF vibetype.jwt_update_guest_add(gen_random_uuid()) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: a guest claim was added to an ended session';
  END IF;

  IF vibetype.jwt_update_attendance_add(gen_random_uuid()) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: an attendance claim was added to an ended session';
  END IF;

  IF EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE id = _jwt.jti) THEN
    RAISE EXCEPTION 'Test failed: an ended session was stored again';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT ended;

-- Without a session, adding a claim starts one.
SAVEPOINT started;
DO $$
BEGIN
  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  PERFORM set_config('jwt.claims.jti', '', true);

  IF vibetype.jwt_update_guest_add(gen_random_uuid()) IS NULL THEN
    RAISE EXCEPTION 'Test failed: a guest claim did not start a session';
  END IF;

  IF vibetype.jwt_update_attendance_add(gen_random_uuid()) IS NULL THEN
    RAISE EXCEPTION 'Test failed: an attendance claim did not start a session';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT started;

ROLLBACK;
