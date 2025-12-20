\echo test_jwt_update_attendance_add...

BEGIN;

SAVEPOINT jwt_update_attendance_add_success;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
  _guest_id UUID;
  _attendance_id UUID;
  _jwt_updated vibetype.jwt;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  -- Create event, guest, and attendance
  PERFORM vibetype_test.invoker_set(_account_id);

  _guest_id := vibetype_test.guest_create(
    _account_id,
    vibetype_test.event_create(_account_id, 'Test Event', 'test-event', '2025-06-01 20:00', 'public'),
    vibetype_test.contact_create(_account_id, 'contact@example.com')
  );

  INSERT INTO vibetype.attendance (guest_id) VALUES (_guest_id) RETURNING id INTO _attendance_id;

  -- Create JWT for the account
  PERFORM vibetype_test.invoker_set_previous();
  _jwt := vibetype.jwt_create('username', 'password');

  -- Set JWT claims in session
  PERFORM vibetype_test.invoker_set(_account_id);
  PERFORM set_config('jwt.claims.jti', _jwt.jti::TEXT, true);
  PERFORM set_config('jwt.claims.exp', _jwt.exp::TEXT, true);
  PERFORM set_config('jwt.claims.guests', '[' || COALESCE(string_agg('"' || g.id::TEXT || '"', ','), '') || ']', true)
    FROM vibetype.guest g WHERE g.contact_id = (SELECT id FROM vibetype.contact WHERE account_id = _account_id LIMIT 1);
  PERFORM set_config('jwt.claims.role', _jwt.role::TEXT, true);
  PERFORM set_config('jwt.claims.attendances', '[]', true);
  PERFORM set_config('jwt.claims.username', _jwt.username::TEXT, true);

  -- Call function to add attendance
  _jwt_updated := vibetype.jwt_update_attendance_add(_attendance_id);

  IF _jwt_updated IS NULL THEN
    RAISE EXCEPTION 'Test failed: jwt_update_attendance_add should return a JWT';
  END IF;

  IF NOT (_attendance_id = ANY(_jwt_updated.attendances)) THEN
    RAISE EXCEPTION 'Test failed: jwt_update_attendance_add should add attendance to attendances array';
  END IF;

  IF _jwt_updated.exp <> _jwt.exp THEN
    RAISE EXCEPTION 'Test failed: jwt_update_attendance_add should preserve exp';
  END IF;

  IF _jwt_updated.sub <> _jwt.sub THEN
    RAISE EXCEPTION 'Test failed: jwt_update_attendance_add should preserve sub';
  END IF;

  IF _jwt_updated.username <> _jwt.username THEN
    RAISE EXCEPTION 'Test failed: jwt_update_attendance_add should preserve username';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT jwt_update_attendance_add_success;

SAVEPOINT jwt_update_attendance_add_multiple;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
  _guest_id_1 UUID;
  _guest_id_2 UUID;
  _attendance_id_1 UUID;
  _attendance_id_2 UUID;
  _jwt_updated vibetype.jwt;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  -- Create event, guests, and attendances
  PERFORM vibetype_test.invoker_set(_account_id);

  _guest_id_1 := vibetype_test.guest_create(
    _account_id,
    vibetype_test.event_create(_account_id, 'Test Event 1', 'test-event-1', '2025-06-01 20:00', 'public'),
    vibetype_test.contact_create(_account_id, 'contact1@example.com')
  );

  _guest_id_2 := vibetype_test.guest_create(
    _account_id,
    vibetype_test.event_create(_account_id, 'Test Event 2', 'test-event-2', '2025-06-01 21:00', 'public'),
    vibetype_test.contact_create(_account_id, 'contact2@example.com')
  );

  INSERT INTO vibetype.attendance (guest_id) VALUES (_guest_id_1) RETURNING id INTO _attendance_id_1;
  INSERT INTO vibetype.attendance (guest_id) VALUES (_guest_id_2) RETURNING id INTO _attendance_id_2;

  -- Create JWT for the account
  PERFORM vibetype_test.invoker_set_previous();
  _jwt := vibetype.jwt_create('username', 'password');

  -- Set JWT claims in session
  PERFORM vibetype_test.invoker_set(_account_id);
  PERFORM set_config('jwt.claims.guests', '["' || _guest_id_1::TEXT || '"]', true);
  PERFORM set_config('jwt.claims.jti', _jwt.jti::TEXT, true);
  PERFORM set_config('jwt.claims.exp', _jwt.exp::TEXT, true);
  PERFORM set_config('jwt.claims.role', _jwt.role::TEXT, true);
  PERFORM set_config('jwt.claims.attendances', '[' || COALESCE(string_agg('"' || _attendance_id_1::TEXT || '"', ','), '') || ']', true);
  PERFORM set_config('jwt.claims.username', _jwt.username::TEXT, true);

  -- Add second attendance
  _jwt_updated := vibetype.jwt_update_attendance_add(_attendance_id_2);

  IF NOT (_attendance_id_1 = ANY(_jwt_updated.attendances) AND _attendance_id_2 = ANY(_jwt_updated.attendances)) THEN
    RAISE EXCEPTION 'Test failed: jwt_update_attendance_add should preserve existing and add new attendance';
  END IF;

  IF array_length(_jwt_updated.attendances, 1) <> 2 THEN
    RAISE EXCEPTION 'Test failed: jwt_update_attendance_add should have 2 attendances';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT jwt_update_attendance_add_multiple;

ROLLBACK;
